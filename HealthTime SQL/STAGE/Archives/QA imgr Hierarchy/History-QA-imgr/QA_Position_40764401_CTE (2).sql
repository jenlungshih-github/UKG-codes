-- QA Script: Check why MANAGER_POSITION_NBR='40764401' has no value in CTE_Position_HR_Status
-- This script investigates the CTE logic step by step

USE [HealthTime];
GO

PRINT 'QA Analysis for MANAGER_POSITION_NBR = 40764401';
PRINT '================================================';

-- Step 1: Check if position exists in temp1
PRINT 'Step 1: Check temp1 for positions with MANAGER_POSITION_NBR = 40764401';
IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL 
BEGIN
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1
    FROM #temp1
    WHERE MANAGER_POSITION_NBR = '40764401'
    ORDER BY POSITION_NBR_To_Check;

    IF @@ROWCOUNT = 0
        PRINT 'No records found in temp1 with MANAGER_POSITION_NBR = 40764401';
    ELSE
        PRINT 'Records found in temp1 with MANAGER_POSITION_NBR = 40764401';
END
ELSE
    PRINT 'temp1 table does not exist - run the stored procedure first';

PRINT '';
PRINT 'Step 2: Check JobData CTE for POSITION_NBR = 40764401';

-- Step 2: Check JobData CTE
;
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
    )
SELECT
    POSITION_NBR,
    EMPLID,
    HR_STATUS,
    EMPL_RCD,
    JOBCODE,
    EFFDT,
    ROWNO
FROM JobData
WHERE POSITION_NBR = '40764401';

PRINT '';
PRINT 'Step 3: Check PositionData CTE for POSITION_NBR = 40764401';

-- Step 3: Check PositionData CTE
;
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
SELECT
    POSN_STATUS,
    deptid,
    POSITION_NBR,
    EFFDT,
    DML_IND,
    RN
FROM PositionData
WHERE POSITION_NBR = '40764401';

PRINT '';
PRINT 'Step 4: Check CTE_Position_HR_Status for POSITION_NBR = 40764401';

-- Step 4: Check full CTE_Position_HR_Status
;
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
            jd.HR_STATUS,
            pd.POSN_STATUS,
            pd.EFFDT as POSITION_EFFDT
        FROM JobData jd
            JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
        WHERE 
            pd.RN = 1
            AND jd.ROWNO = 1
    )
SELECT
    POSITION_NBR,
    EMPLID,
    HR_STATUS,
    POSN_STATUS,
    POSITION_EFFDT
FROM CTE_Position_HR_Status
WHERE POSITION_NBR = '40764401';

PRINT '';
PRINT 'Step 5: Check if JOIN condition fails between JobData and PositionData';

-- Step 5: Check why JOIN might fail
;
WITH
    JobData
    AS
    (
        SELECT
            J.POSITION_NBR,
            J.EMPLID,
            J.HR_STATUS,
            ROW_NUMBER() OVER (PARTITION BY J.EMPLID ORDER BY
                (CASE WHEN J.JOB_INDICATOR = 'N' THEN 'Z' ELSE J.JOB_INDICATOR END), 
                EFFDT DESC) as ROWNO
        FROM health_ods.[HEALTH_ODS].[STABLE].PS_JOB J
        WHERE 
            J.DML_IND <> 'D'
            AND J.POSITION_NBR = '40764401'
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
    PositionData
    AS
    (
        SELECT
            POSN_STATUS,
            POSITION_NBR,
            EFFDT,
            ROW_NUMBER() OVER (PARTITION BY POSITION_NBR ORDER BY effdt DESC) as RN
        FROM health_ods.[health_ods].stable.PS_POSITION_DATA
        WHERE dml_ind <> 'D'
            AND POSITION_NBR = '40764401'
    )
    SELECT
        'JobData' as Source,
        jd.POSITION_NBR,
        jd.EMPLID,
        jd.HR_STATUS,
        jd.ROWNO,
        CAST(NULL as VARCHAR(10)) as POSN_STATUS,
        CAST(NULL as INT) as RN
    FROM JobData jd
    WHERE jd.ROWNO = 1

UNION ALL

    SELECT
        'PositionData' as Source,
        pd.POSITION_NBR,
        CAST(NULL as VARCHAR(20)) as EMPLID,
        CAST(NULL as VARCHAR(10)) as HR_STATUS,
        CAST(NULL as INT) as ROWNO,
        pd.POSN_STATUS,
        pd.RN
    FROM PositionData pd
    WHERE pd.RN = 1

UNION ALL

    SELECT
        'JOINED' as Source,
        jd.POSITION_NBR,
        jd.EMPLID,
        jd.HR_STATUS,
        jd.ROWNO,
        pd.POSN_STATUS,
        pd.RN
    FROM JobData jd
        JOIN PositionData pd ON pd.POSITION_NBR = jd.POSITION_NBR
    WHERE pd.RN = 1
--AND jd.ROWNO = 1
;

PRINT '';
PRINT 'QA Analysis Complete';
PRINT '===================';
