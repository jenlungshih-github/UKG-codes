USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_Create_Position_Trace_Analysis]    Script Date: 9/1/2025 6:37:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [stage].[SP_Create_Position_Trace_Analysis]
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
        imgr.POSITION_NBR as POSITION_NBR_To_Check,
        empl.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR,
        L.POSN_LEVEL,
        CASE 
            WHEN L.POSN_LEVEL IS NULL THEN 'yes'
            ELSE 'no'
        END as To_Trace_Up_1
    FROM [stage].[UKG_EMPL_Inactive_Manager] imgr
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        ON empl.emplid = imgr.[Inactive_EMPLID]
            AND empl.POSITION_NBR = imgr.POSITION_NBR
        LEFT JOIN PositionData pd
        ON pd.POSITION_NBR = empl.[POSITION_REPORTS_TO]
            AND pd.RN = 1
        LEFT JOIN [stage].[UKG_ManagerHierarchy] L
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

    SELECT DISTINCT
        t1.POSITION_NBR_To_Check,
        t1.MANAGER_POSITION_NBR,
        --A.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR,
        t1.POSN_LEVEL,
        t1.To_Trace_Up_1,
        A.MANAGER_POSITION_NBR as MANAGER_POSITION_NBR_L1,
        A.[PS_JOB_EMPLID] as MANAGER_EMPLID,
        A.[PS_JOB_HR_STATUS] as MANAGER_HR_STATUS,
        A.[POSN_STATUS] as MANAGER_POSN_STATUS,
        L.POSN_LEVEL as MANAGER_POSN_LEVEL,
        CASE 
            WHEN A.[PS_JOB_HR_STATUS] = 'A' THEN 'no'
            ELSE 'yes'
        END as To_Trace_Up_2
    INTO #temp2
    FROM #temp1 t1
        LEFT JOIN (
            SELECT
            [POSITION_REPORTS_TO] AS MANAGER_POSITION_NBR,
            [PS_JOB_EMPLID],
            [PS_JOB_HR_STATUS],
            [POSN_STATUS]
        FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] A
        WHERE A.[LEVEL UP] = 1
            AND
            A.NOTE <> 'missing in PS_JOB'
        ) A ON t1.MANAGER_POSITION_NBR = A.MANAGER_POSITION_NBR
        LEFT JOIN [stage].[UKG_ManagerHierarchy] L
        ON A.MANAGER_POSITION_NBR = L.POSITION_NBR
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
        To_Trace_Up_2
    FROM #temp2
    ORDER BY POSITION_NBR_To_Check;

    -- Create temp3 by joining To_Trace_Up_2='yes' records with Level 2 analysis data
    IF OBJECT_ID('tempdb..#temp3', 'U') IS NOT NULL 
        DROP TABLE #temp3;

    SELECT
        t2.POSITION_NBR_To_Check,
        --    t2.MANAGER_POSITION_NBR,
        t2.MANAGER_POSITION_NBR_L1 as MANAGER_POSITION_NBR,
        t2.POSN_LEVEL,
        t2.To_Trace_Up_1,
        t2.MANAGER_POSITION_NBR_L1,
        t2.MANAGER_EMPLID,
        t2.MANAGER_HR_STATUS,
        t2.MANAGER_POSN_STATUS,
        t2.MANAGER_POSN_LEVEL,
        t2.To_Trace_Up_2,
        B.[POSITION_REPORTS_TO] as MANAGER_POSITION_NBR_L2,
        B.[PS_JOB_EMPLID] as MANAGER_EMPLID_L2,
        B.[PS_JOB_HR_STATUS] as MANAGER_HR_STATUS_L2,
        B.[POSN_STATUS] as MANAGER_POSN_STATUS_L2,
        L2.POSN_LEVEL as MANAGER_POSN_LEVEL_L2,
        CASE 
        WHEN B.[PS_JOB_HR_STATUS] = 'A' THEN 'no'
        ELSE 'yes'
    END as To_Trace_Up_3
    INTO #temp3
    FROM #temp2 t2
        LEFT JOIN [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] B
        ON t2.MANAGER_EMPLID = B.[Inactive_EMPLID]
            AND B.[LEVEL UP] = 2
            AND B.NOTE <> 'missing in PS_JOB'
        LEFT JOIN [stage].[UKG_ManagerHierarchy] L2
        ON B.[POSITION_REPORTS_TO] = L2.POSITION_NBR
    WHERE t2.To_Trace_Up_2 = 'yes'
    ORDER BY POSITION_NBR_To_Check;


    SELECT *
    FROM #temp3
    ORDER BY POSITION_NBR_To_Check;


    PRINT 'Position Trace Analysis completed successfully.';
    PRINT 'Temp tables #temp1, #temp2, and #temp3 are available for further analysis in this session.';

END
GO


