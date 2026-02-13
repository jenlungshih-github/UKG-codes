USE [HealthTime]
GO

-- QA Script for Position Trace Analysis - LEVEL UP Investigation
-- Testing with POSITION_NBR_To_Check = 41043636
-- Created: 08/31/2025 by Jim Shih

PRINT 'Starting QA for Position 41043636 - LEVEL UP Investigation...';

-- Step 1: Check LEVEL UP column values and data distribution
PRINT '=== Step 1: LEVEL UP column analysis ===';
SELECT
    [LEVEL UP],
    COUNT(*) as record_count
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
GROUP BY [LEVEL UP]
ORDER BY [LEVEL UP];

-- Step 2: Check data for position 41043708 (the L1 manager) across all levels
PRINT '=== Step 2: Position 41043708 data across all levels ===';
SELECT
    [LEVEL UP],
    [POSITION_REPORTS_TO],
    [PS_JOB_EMPLID],
    [PS_JOB_HR_STATUS],
    [POSN_STATUS]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [POSITION_REPORTS_TO] = '41043708'
ORDER BY [LEVEL UP];

-- Step 3: Check what Level 2 records exist and their structure
PRINT '=== Step 3: Sample Level 2 records ===';
SELECT TOP 10
    [LEVEL UP],
    [POSITION_REPORTS_TO],
    [PS_JOB_EMPLID],
    [PS_JOB_HR_STATUS],
    [POSN_STATUS],
    [Inactive_EMPLID_POSITION_NBR]
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
WHERE [LEVEL UP] = 2
ORDER BY [POSITION_REPORTS_TO];

-- Step 4: Trace the hierarchy for position 41043636
PRINT '=== Step 4: Full hierarchy trace for 41043636 ===';

-- Level 0: Original position
    SELECT
        0 as trace_level,
        '41043636' as position_in_hierarchy,
        imgr.[Inactive_EMPLID],
        empl.[POSITION_REPORTS_TO] as reports_to_position
    FROM [stage].[UKG_EMPL_Inactive_Manager] imgr
        LEFT JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
        ON empl.emplid = imgr.[Inactive_EMPLID] AND empl.POSITION_NBR = imgr.POSITION_NBR
    WHERE imgr.POSITION_NBR = '41043636'

UNION ALL

    -- Level 1: Manager of 41043636 
    SELECT
        1 as trace_level,
        L1.[POSITION_REPORTS_TO] as position_in_hierarchy,
        L1.[PS_JOB_EMPLID],
        L1.[POSITION_REPORTS_TO] as reports_to_position
    FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] L1
    WHERE L1.[LEVEL UP] = 1
        AND L1.[POSITION_REPORTS_TO] = '41043708'

UNION ALL

    -- Level 2: Manager of the Level 1 manager
    SELECT
        2 as trace_level,
        L2.[POSITION_REPORTS_TO] as position_in_hierarchy,
        L2.[PS_JOB_EMPLID],
        'Check_L2_Manager' as reports_to_position
    FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] L2
    WHERE L2.[LEVEL UP] = 2
ORDER BY trace_level;

-- Step 5: Check if we need to join differently for Level 2
PRINT '=== Step 5: Correct Level 2 join logic check ===';
-- Find who the Level 1 manager (41043708) reports to by looking at Level 2 data
SELECT
    'Level_1_Manager_Check' as step,
    L1.[POSITION_REPORTS_TO] as level_1_manager_position,
    L1.[PS_JOB_EMPLID] as level_1_manager_emplid,
    L2.[POSITION_REPORTS_TO] as who_level_1_manager_reports_to,
    L2.[PS_JOB_EMPLID] as level_2_manager_emplid
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] L1
    LEFT JOIN [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] L2
    ON L1.[PS_JOB_EMPLID] = L2.[Inactive_EMPLID] AND L2.[LEVEL UP] = 2
WHERE L1.[LEVEL UP] = 1
    AND L1.[POSITION_REPORTS_TO] = '41043708';

PRINT 'QA completed for Position 41043636.';
