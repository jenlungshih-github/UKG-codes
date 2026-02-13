USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_Create_Position_Trace_Analysis]    Script Date: 9/1/2025 7:40:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




create or ALTER   PROCEDURE [stage].[SP_Create_Position_Trace_Analysis]
AS
-- exec [stage].[SP_Create_Position_Trace_Analysis]
/***************************************
* Created By: Jim Shih	
* Purpose: Create position trace analysis based on inactive manager data with position level tracking
* Table: Processes data from [stage].[UKG_EMPL_Inactive_Manager] and creates temp1 table
* To_Trace_Up_1 Logic: If L.POSN_LEVEL is NULL, then To_Trace_Up_1 = 'yes', otherwise 'no'
* -- 08/31/2025 Jim Shih: Created based on 16.sql query
******************************************/
BEGIN
    SET NOCOUNT ON;

    -- Drop temp table if it exists
    IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL 
        DROP TABLE #temp1;

    -- Create temp table with additional To_Trace_Up_1 column
    CREATE TABLE #temp1
    (
        POSITION_NBR_To_Check VARCHAR(20),
        MANAGER_POSITION_NBR VARCHAR(20),
        POSN_LEVEL VARCHAR(10),
        To_Trace_Up_1 VARCHAR(3)
    );

    PRINT 'Starting Position Trace Analysis...';

    -- Insert data into temp table with To_Trace_Up_1 logic
    WITH
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        )
    INSERT INTO #temp1
        (POSITION_NBR_To_Check, MANAGER_POSITION_NBR, POSN_LEVEL, To_Trace_Up_1)
    SELECT DISTINCT
        imgr.POSITION_NBR_To_Check as POSITION_NBR_To_Check,
        empl.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR,
        L.POSN_LEVEL,
        CASE 
            WHEN L.POSN_LEVEL IS NULL THEN 'yes'
            ELSE 'no'
        END as To_Trace_Up_1
    FROM [stage].[UKG_EMPL_Inactive_Manager] imgr
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        ON empl.emplid = imgr.[Inactive_EMPLID_To_Check]
            AND empl.POSITION_NBR = imgr.POSITION_NBR_To_Check
        LEFT JOIN PositionData pd
        ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
            AND pd.RN = 1
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
        ON empl.[POSITION_REPORTS_TO] = L.POSITION_NBR;

    -- Show temp1 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1
    FROM #temp1
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp2 by joining To_Trace_Up_1='yes' records with Level 1 analysis data
    IF OBJECT_ID('tempdb..#temp2', 'U') IS NOT NULL 
        DROP TABLE #temp2;

    WITH
        JobData
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData
            WHERE ROWNO = 1
        ),
        CurrentEmplData
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData
            WHERE RN_EMPL = 1
        ),
        PositionData
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered jd
                JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered empl ON empl.POSITION_NBR = jd.POSITION_NBR
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT
            FROM CTE_Position_HR_Status
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level
        -- Note that this CTE is added to get POSN_LEVEL for manager positions is NULL, means JOB_INDICATOR is not 'P' or'N'
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t1.POSITION_NBR_To_Check,
        t1.MANAGER_POSITION_NBR,
        t1.POSN_LEVEL,
        t1.To_Trace_Up_1,
        t1.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        CTE_Position_HR_Status_Final.EMPLID as MANAGER_EMPLID,
        CTE_Position_HR_Status_Final.HR_STATUS as MANAGER_HR_STATUS,
        CTE_Position_HR_Status_Final.POSN_STATUS as MANAGER_POSN_STATUS,
        COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) as MANAGER_POSN_LEVEL,
        CASE 
            WHEN CTE_Position_HR_Status_Final.EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L.POSN_LEVEL, L2.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_Final.HR_STATUS = 'A'
            AND CTE_Position_HR_Status_Final.POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE,
        CASE 
            WHEN CTE_Position_HR_Status_Final.HR_STATUS = 'A' OR CTE_Position_HR_Status_Final.HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_2

    INTO #temp2
    FROM #temp1 t1
        LEFT JOIN CTE_Position_HR_Status_Final ON t1.MANAGER_POSITION_NBR = CTE_Position_HR_Status_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L ON t1.MANAGER_POSITION_NBR = L.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level L2 ON t1.MANAGER_POSITION_NBR = L2.POSITION_NBR
    WHERE t1.To_Trace_Up_1 = 'yes';

    -- Show temp2 results
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        MANAGER_POSITION_NBR_L1,
        MANAGER_EMPLID,
        MANAGER_HR_STATUS,
        MANAGER_POSN_STATUS,
        MANAGER_POSN_LEVEL,
        To_Trace_Up_2,
        NOTE
    FROM #temp2
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp3 by joining To_Trace_Up_2='yes' records with Level 2 analysis data
    IF OBJECT_ID('tempdb..#temp3', 'U') IS NOT NULL 
        DROP TABLE #temp3;

    WITH
        JobData_L2
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L2
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L2
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L2
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L2
            WHERE RN_EMPL = 1
        ),
        PositionData_L2
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L2
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L2 jd
                JOIN PositionData_L2 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L2 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L2 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L2 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L2_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L2
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L2
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t2.POSITION_NBR_To_Check,
        t2.MANAGER_POSITION_NBR,
        t2.POSN_LEVEL,
        t2.To_Trace_Up_1,
        t2.MANAGER_POSITION_NBR_L1,
        t2.MANAGER_EMPLID,
        t2.MANAGER_HR_STATUS,
        t2.MANAGER_POSN_STATUS,
        t2.MANAGER_POSN_LEVEL,
        t2.To_Trace_Up_2,
        t2.NOTE as NOTE_L1,
        CTE_Position_HR_Status_L2_Final.REPORTS_TO as MANAGER_POSITION_NBR_L2,
        CTE_Position_HR_Status_L2_Final.Manager_EMPLID as MANAGER_EMPLID_L2,
        CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L2,
        CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L2,
        COALESCE(L2.POSN_LEVEL, L3.POSN_LEVEL) as MANAGER_POSN_LEVEL_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L2.POSN_LEVEL, L3.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L2_Final.Manager_EMPLID = 'A'
            AND CTE_Position_HR_Status_L2_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L2,
        CASE 
            WHEN CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L2_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_3
    INTO #temp3
    FROM #temp2 t2
        --    LEFT JOIN CTE_Position_HR_Status_L2_Final ON t2.MANAGER_EMPLID = CTE_Position_HR_Status_L2_Final.EMPLID
        LEFT JOIN CTE_Position_HR_Status_L2_Final ON t2.MANAGER_POSITION_NBR_L1 = CTE_Position_HR_Status_L2_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L2 ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L2.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L2 L3 ON CTE_Position_HR_Status_L2_Final.REPORTS_TO = L3.POSITION_NBR
    WHERE t2.To_Trace_Up_2 = 'yes';


    SELECT *
    FROM #temp3
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp4 by joining To_Trace_Up_3='yes' records with Level 3 analysis data
    IF OBJECT_ID('tempdb..#temp4', 'U') IS NOT NULL 
        DROP TABLE #temp4;

    WITH
        JobData_L3
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L3
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L3
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L3
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L3
            WHERE RN_EMPL = 1
        ),
        PositionData_L3
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L3
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L3 jd
                JOIN PositionData_L3 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L3 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L3 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L3 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L3_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L3
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L3
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t3.POSITION_NBR_To_Check,
        t3.MANAGER_POSITION_NBR_L2 as MANAGER_POSITION_NBR,
        t3.POSN_LEVEL,
        t3.To_Trace_Up_1,
        t3.MANAGER_POSITION_NBR_L1,
        t3.MANAGER_EMPLID,
        t3.MANAGER_HR_STATUS,
        t3.MANAGER_POSN_STATUS,
        t3.MANAGER_POSN_LEVEL,
        t3.To_Trace_Up_2,
        t3.NOTE_L1,
        t3.MANAGER_POSITION_NBR_L2,
        t3.MANAGER_EMPLID_L2,
        t3.MANAGER_HR_STATUS_L2,
        t3.MANAGER_POSN_STATUS_L2,
        t3.MANAGER_POSN_LEVEL_L2,
        t3.To_Trace_Up_3,
        t3.NOTE_L2,
        CTE_Position_HR_Status_L3_Final.REPORTS_TO as MANAGER_POSITION_NBR_L3,
        CTE_Position_HR_Status_L3_Final.Manager_EMPLID as MANAGER_EMPLID_L3,
        CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L3,
        CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L3,
        COALESCE(L3.POSN_LEVEL, L4.POSN_LEVEL) as MANAGER_POSN_LEVEL_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L3.POSN_LEVEL, L4.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L3_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L3,
        CASE 
            WHEN CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L3_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_4
    INTO #temp4
    FROM #temp3 t3
        LEFT JOIN CTE_Position_HR_Status_L3_Final ON t3.MANAGER_POSITION_NBR_L2 = CTE_Position_HR_Status_L3_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L3 ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L3.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L3 L4 ON CTE_Position_HR_Status_L3_Final.REPORTS_TO = L4.POSITION_NBR
    WHERE t3.To_Trace_Up_3 = 'yes';

    SELECT *
    FROM #temp4
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp5 by joining To_Trace_Up_4='yes' records with Level 4 analysis data
    IF OBJECT_ID('tempdb..#temp5', 'U') IS NOT NULL 
        DROP TABLE #temp5;

    WITH
        JobData_L4
        AS
        (
            SELECT
                J.POSITION_NBR,
                J.EMPLID,
                J.HR_STATUS,
                J.EMPL_RCD,
                J.JOBCODE,
                J.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                    (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                    EFFDT DESC) as ROWNO
            FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
            WHERE 
                J.DML_IND <> 'D'
                AND J.EFFDT = (
                    SELECT MAX(J1.EFFDT)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J1
                WHERE J1.EMPLID = J.EMPLID
                    AND J1.EMPL_RCD = J.EMPL_RCD
                    AND J1.EFFDT <= GETDATE()
                    AND J1.DML_IND <> 'D'
                )
                AND J.EFFSEQ = (
                    SELECT MAX(J2.EFFSEQ)
                FROM health_ods.[health_ods].[STABLE].PS_JOB J2
                WHERE J2.EMPLID = J.EMPLID
                    AND J2.EMPL_RCD = J.EMPL_RCD
                    AND J2.EFFDT = J.EFFDT
                    AND J2.DML_IND <> 'D'
                )
        ),
        JobDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                EMPL_RCD,
                JOBCODE,
                EFFDT,
                ROWNO
            FROM JobData_L4
            WHERE ROWNO = 1
        ),
        CurrentEmplData_L4
        AS
        (
            SELECT
                empl.POSITION_NBR,
                empl.Reports_To,
                empl.HR_STATUS,
                empl.emplid,
                empl.EMPL_RCD,
                empl.EFFDT,
                ROW_NUMBER() OVER (PARTITION BY empl.emplid ORDER BY empl.EFFDT DESC) as RN_EMPL
            FROM health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] EMPL
        ),
        CurrentEmplDataFiltered_L4
        AS
        (
            SELECT
                POSITION_NBR,
                Reports_To,
                HR_STATUS,
                emplid,
                EMPL_RCD,
                EFFDT,
                RN_EMPL
            FROM CurrentEmplData_L4
            WHERE RN_EMPL = 1
        ),
        PositionData_L4
        AS
        (
            SELECT
                POSN_STATUS,
                deptid,
                POSITION_NBR,
                EFFDT,
                DML_IND,
                ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
            FROM health_ods.[health_ods].stable.PS_POSITION_DATA
            WHERE dml_ind <> 'D'
        ),
        CTE_Position_HR_Status_L4
        AS
        (
            SELECT
                jd.POSITION_NBR,
                jd.EMPLID,
                empl.HR_STATUS,
                pd.POSN_STATUS,
                pd.EFFDT as POSITION_EFFDT,
                empl.EFFDT as EMPL_EFFDT,
                empl.Reports_To,
                jd2.EMPLID as Manager_EMPLID,
                jd2.HR_STATUS as Manager_HR_STATUS,
                pd2.POSN_STATUS as Manager_POSN_STATUS,
                ROW_NUMBER() OVER (PARTITION BY jd.POSITION_NBR ORDER BY empl.EFFDT DESC) as RN_FINAL
            FROM JobDataFiltered_L4 jd
                JOIN PositionData_L4 pd ON pd.POSITION_NBR = jd.POSITION_NBR
                JOIN CurrentEmplDataFiltered_L4 empl ON empl.POSITION_NBR = jd.POSITION_NBR
                LEFT JOIN JobDataFiltered_L4 jd2 ON jd2.POSITION_NBR = empl.Reports_To
                LEFT JOIN PositionData_L4 pd2 ON pd2.POSITION_NBR = empl.Reports_To AND pd2.RN = 1
            WHERE 
                pd.RN = 1
        ),
        CTE_Position_HR_Status_L4_Final
        AS
        (
            SELECT
                POSITION_NBR,
                EMPLID,
                HR_STATUS,
                POSN_STATUS,
                POSITION_EFFDT,
                EMPL_EFFDT,
                Reports_To,
                Manager_EMPLID,
                Manager_HR_STATUS,
                Manager_POSN_STATUS
            FROM CTE_Position_HR_Status_L4
            WHERE RN_FINAL = 1
        ),
        CTE_Hierarchy_Posn_Level_L4
        AS
        (
            SELECT
                empl.emplid,
                empl.POSITION_NBR,
                EMPL.JOB_INDICATOR,
                HPOSN.LEVEL as POSN_LEVEL,
                GETDATE() AS UPDATED_DT
            FROM health_ods.health_ods.[RPT].[CURRENT_EMPL_DATA] EMPL
                JOIN health_ods.[RPT].ORG_HIERARCHY_POSN HPOSN
                ON HPOSN.EMPLID = EMPL.EMPLID
                    AND HPOSN.EMPL_RCD = EMPL.EMPL_RCD
            WHERE empl.HR_STATUS='A'
        )
    SELECT DISTINCT
        t4.POSITION_NBR_To_Check,
        t4.MANAGER_POSITION_NBR_L3 as MANAGER_POSITION_NBR,
        t4.POSN_LEVEL,
        t4.To_Trace_Up_1,
        t4.MANAGER_POSITION_NBR_L1,
        t4.MANAGER_EMPLID,
        t4.MANAGER_HR_STATUS,
        t4.MANAGER_POSN_STATUS,
        t4.MANAGER_POSN_LEVEL,
        t4.To_Trace_Up_2,
        t4.NOTE_L1,
        t4.MANAGER_POSITION_NBR_L2,
        t4.MANAGER_EMPLID_L2,
        t4.MANAGER_HR_STATUS_L2,
        t4.MANAGER_POSN_STATUS_L2,
        t4.MANAGER_POSN_LEVEL_L2,
        t4.To_Trace_Up_3,
        t4.NOTE_L2,
        t4.MANAGER_POSITION_NBR_L3,
        t4.MANAGER_EMPLID_L3,
        t4.MANAGER_HR_STATUS_L3,
        t4.MANAGER_POSN_STATUS_L3,
        t4.MANAGER_POSN_LEVEL_L3,
        t4.To_Trace_Up_4,
        t4.NOTE_L3,
        CTE_Position_HR_Status_L4_Final.REPORTS_TO as MANAGER_POSITION_NBR_L4,
        CTE_Position_HR_Status_L4_Final.Manager_EMPLID as MANAGER_EMPLID_L4,
        CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS as MANAGER_HR_STATUS_L4,
        CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS as MANAGER_POSN_STATUS_L4,
        COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) as MANAGER_POSN_LEVEL_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_EMPLID IS NULL THEN 'missing in PS_JOB'
            WHEN COALESCE(L4.POSN_LEVEL, L5.POSN_LEVEL) IS NULL
            AND CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A'
            AND CTE_Position_HR_Status_L4_Final.Manager_POSN_STATUS = 'A' THEN 'missing POSN_LEVEL in ORG_HIERARCHY_POSN'
            ELSE ''
        END as NOTE_L4,
        CASE 
            WHEN CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS = 'A' OR CTE_Position_HR_Status_L4_Final.Manager_HR_STATUS IS NULL THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_5
    INTO #temp5
    FROM #temp4 t4
        LEFT JOIN CTE_Position_HR_Status_L4_Final ON t4.MANAGER_POSITION_NBR_L3 = CTE_Position_HR_Status_L4_Final.POSITION_NBR
        LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L4 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L4.POSITION_NBR
        LEFT JOIN CTE_Hierarchy_Posn_Level_L4 L5 ON CTE_Position_HR_Status_L4_Final.REPORTS_TO = L5.POSITION_NBR
    WHERE t4.To_Trace_Up_4 = 'yes';

    SELECT *
    FROM #temp5
    ORDER BY POSITION_NBR_To_Check;


    PRINT 'Position Trace Analysis completed successfully.';
    PRINT 'Temp tables #temp1, #temp2, #temp3, #temp4, and #temp5 are available for further analysis in this session.';

END
GO


