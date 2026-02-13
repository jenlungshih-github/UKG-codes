USE [HealthTime]
GO

-- QA Script for Position 40653963 missing from temp2
-- Investigating why MANAGER_POSITION_NBR 40653963 is in temp1 but not temp2

PRINT 'QA for Position 40653963 - Missing from temp2...';

-- Step 1: Check what's in temp1 for positions that report to 40653963
PRINT '=== Step 1: temp1 records for manager position 40653963 ===';
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
    'temp1_simulation' as step,
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
    LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] L
    ON empl.[POSITION_REPORTS_TO] = L.POSITION_NBR
WHERE empl.[POSITION_REPORTS_TO] = '40653963';

-- Step 2: Check if position 40653963 exists in Level 1 analysis data
PRINT '=== Step 2: Check Level 1 analysis data for position 40653963 ===';
SELECT
    'Level_1_check' as step,
    [POSITION_REPORTS_TO],
    [PS_JOB_EMPLID],
    [PS_JOB_HR_STATUS],
    [POSN_STATUS],
    [NOTE],
    [LEVEL UP]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [POSITION_REPORTS_TO] = '40653963'
    AND [LEVEL UP] = 1;

-- Step 3: Check if there are any Level 1 records with NOTE = 'missing in PS_JOB'
PRINT '=== Step 3: Check if position 40653963 has "missing in PS_JOB" note ===';
SELECT
    'Note_check' as step,
    [POSITION_REPORTS_TO],
    [PS_JOB_EMPLID],
    [PS_JOB_HR_STATUS],
    [POSN_STATUS],
    [NOTE],
    [LEVEL UP]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [POSITION_REPORTS_TO] = '40653963'
    AND [LEVEL UP] = 1
    AND [NOTE] = 'missing in PS_JOB';

-- Step 4: Check what happens if we remove the NOTE filter
PRINT '=== Step 4: temp2 simulation without NOTE filter ===';
SELECT
    'temp2_without_note_filter' as step,
    A.[POSITION_REPORTS_TO] AS MANAGER_POSITION_NBR_L1,
    A.[PS_JOB_EMPLID],
    A.[PS_JOB_HR_STATUS],
    A.[POSN_STATUS],
    A.[NOTE]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] A
WHERE A.[LEVEL UP] = 1
    AND A.[POSITION_REPORTS_TO] = '40653963';

-- Step 5: Check what happens with the current NOTE filter
PRINT '=== Step 5: temp2 simulation with current NOTE filter ===';
SELECT
    'temp2_with_note_filter' as step,
    A.[POSITION_REPORTS_TO] AS MANAGER_POSITION_NBR_L1,
    A.[PS_JOB_EMPLID],
    A.[PS_JOB_HR_STATUS],
    A.[POSN_STATUS],
    A.[NOTE]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] A
WHERE A.[LEVEL UP] = 1
    AND A.[POSITION_REPORTS_TO] = '40653963'
    AND A.NOTE <> 'missing in PS_JOB';

PRINT 'QA completed for Position 40653963.';
