USE [HealthTime]
GO

/***************************************
* QA Script: Check MANAGER_POSITION_NBR 40653963
* Purpose: Diagnose why this position is in #temp1 but not in #temp2
* Created By: Jim Shih
* Date: 09/01/2025
****************************************/

/*
This script assumes that [stage].[SP_Create_Position_Trace_Analysis] has already been executed
and the temp tables #temp1 and #temp2 are still available in the session.
If temp tables don't exist, run the stored procedure first:
EXEC [stage].[SP_Create_Position_Trace_Analysis]
*/

-- STEP 1: Check if the position exists in #temp1
PRINT '=== STEP 1: Check #temp1 for MANAGER_POSITION_NBR 40653963 ===';
IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL
BEGIN
    SELECT
        'Position exists in #temp1' as Status,
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1
    FROM #temp1
    WHERE MANAGER_POSITION_NBR = '40653963';
END
ELSE
BEGIN
    PRINT 'ERROR: #temp1 table does not exist. Please run [stage].[SP_Create_Position_Trace_Analysis] first.';
    RETURN;
END

-- STEP 2: Check if position exists in #temp2
PRINT '=== STEP 2: Check #temp2 for MANAGER_POSITION_NBR 40653963 ===';
IF OBJECT_ID('tempdb..#temp2', 'U') IS NOT NULL
BEGIN
    SELECT
        'Position exists in #temp2' as Status,
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
    WHERE MANAGER_POSITION_NBR_L1 = '40653963';
END
ELSE
BEGIN
    PRINT 'WARNING: #temp2 table does not exist. Please run [stage].[SP_Create_Position_Trace_Analysis] first.';
END

-- STEP 3: Diagnose the data issue
PRINT '=== STEP 3: Diagnosis ===';

-- Check To_Trace_Up_1 status
PRINT '-- Check To_Trace_Up_1 status for position in #temp1 --'
SELECT
    MANAGER_POSITION_NBR,
    To_Trace_Up_1,
    CASE
        WHEN To_Trace_Up_1 = 'yes' THEN 'Position will be processed for temp2 creation'
        ELSE 'Position will NOT be processed for temp2 creation (this is why it is missing from temp2)'
    END as To_Trace_Status_Explanation
FROM #temp1
WHERE MANAGER_POSITION_NBR = '40653963';

-- Check if position exists in source table that feeds temp2
PRINT '-- Check source table [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] for<|pad|><content>
<content>
USE [HealthTime]
GO

/***************************************
* QA Script: Check MANAGER_POSITION_NBR 40653963
* Purpose: Diagnose why this position is in #temp1 but not in #temp2
* Created By: Jim Shih
* Date: 09/01/2025
****************************************/

/*
This script assumes that [stage].[SP_Create_Position_Trace_Analysis] has already been executed
and the temp tables #temp1 and #temp2 are still available in the session.
If temp tables don'
t exist, run the stored procedure
first:
EXEC [stage].[SP_Create_Position_Trace_Analysis]
*/

-- STEP 1: Check if the position exists in #temp1
PRINT '=== STEP 1: Check #temp1 for MANAGER_POSITION_NBR 40653963 ===';
IF OBJECT_ID('tempdb..#temp1', 'U') IS NOT NULL
BEGIN
    SELECT
        POSITION_NBR_To_Check,
        MANAGER_POSITION_NBR,
        POSN_LEVEL,
        To_Trace_Up_1,
        CASE
            WHEN To_Trace_Up_1 = 'yes' THEN 'Can proceed to temp2'
            ELSE 'Cannot proceed to temp2'
        END as Can_Proceed_To_Temp2
    FROM #temp1
    WHERE MANAGER_POSITION_NBR = '40653963';
END
ELSE
BEGIN
    PRINT 'ERROR: #temp1 table does not exist. Please run [stage].[SP_Create_Position_Trace_Analysis] first.';
    RETURN;
END

-- STEP 2: Check if position exists in #temp2
PRINT '=== STEP 2: Check #temp2 for MANAGER_POSITION_NBR 40653963 ===';
IF OBJECT_ID('tempdb..#temp2', 'U') IS NOT NULL
BEGIN
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
    WHERE MANAGER_POSITION_NBR_L1 = '40653963'
        OR POSITION_NBR_To_Check = '40653963';

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Position does NOT exist in #temp2 - this confirms the QA issue';
    END
END
ELSE
BEGIN
    PRINT 'WARNING: #temp2 table does not exist. Please run [stage].[SP_Create_Position_Trace_Analysis] first.';
END

-- STEP 3: Diagnose the data issue
PRINT '=== STEP 3: Diagnosis ===';

-- Check To_Trace_Up_1 status
PRINT '-- Reason Analysis --'
SELECT
    MANAGER_POSITION_NBR,
    To_Trace_Up_1,
    CASE
        WHEN To_Trace_Up_1 = 'yes' THEN 'This position should be processed into #temp2'
        WHEN To_Trace_Up_1 = 'no' THEN 'This position does NOT get processed into #temp2 because To_Trace_Up_1 = ''no'' (NULL POSN_LEVEL in hierarchy lookup)'
        ELSE 'Unknown To_Trace_Up_1 value'
    END as Issue_Explanation
FROM #temp1
WHERE MANAGER_POSITION_NBR = '40653963';

-- Check if the position exists in the source table that feeds temp2 creation
PRINT '-- Check if position exists in the source table used to populate #temp2 --'
SELECT
    'Source table check' as Check_Type,
    COUNT(*) as Record_Count,
    CASE
        WHEN COUNT(*) > 0 THEN 'Position FOUND in source - check for NOTE or LEVEL UP filter'
        ELSE 'Position NOT FOUND in source table'
    END as Status
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] A
WHERE A.[POSITION_REPORTS_TO] = '40653963'
    AND A.[LEVEL UP] = 1
    AND A.NOTE <> 'missing in PS_JOB';

-- Additional diagnostic queries
PRINT '-- Additional Diagnostic Information --'

-- Show the actual record from the source table if it exists with problematic conditions
SELECT
    A.POSITION_REPORTS_TO,
    A.[LEVEL UP],
    A.NOTE,
    A.[PS_JOB_HR_STATUS],
    A.[POSN_STATUS],
    CASE
        WHEN A.NOTE = 'missing in PS_JOB' THEN 'FILTERED OUT: NOTE = missing in PS_JOB'
        WHEN A.[LEVEL UP] != 1 THEN 'FILTERED OUT: LEVEL UP != 1'
        ELSE 'Position should be included in temp2'
    END as Filter_Reason
FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] A
WHERE A.[POSITION_REPORTS_TO] = '40653963';

-- Check the hierarchy lookup for this position
PRINT '-- Check position hierarchy lookup --'
SELECT
    POSITION_NBR,
    POSN_LEVEL,
    CASE
        WHEN POSN_LEVEL IS NULL THEN 'NULL POSN_LEVEL = To_Trace_Up_1 = yes'
        WHEN POSN_LEVEL IS NOT NULL THEN 'HAS POSN_LEVEL = To_Trace_Up_1 = no'
        ELSE 'Unexpected POSN_LEVEL value'
    END as Hierarchy_Status
FROM [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP]
WHERE POSITION_NBR = '40653963';

-- STEP 4: Summary report
PRINT '=== STEP 4: SUMMARY REPORT ===';

WITH
    Diagnosis
    AS
    (
        SELECT
            t1.POSITION_NBR_To_Check,
            t1.MANAGER_POSITION_NBR as Manager_Pos_Nbr,
            t1.To_Trace_Up_1,
            CASE WHEN t2.POSITION_NBR_To_Check IS NOT NULL THEN 'Yes' ELSE 'No' END as Exists_In_Temp2,
            h.POSN_LEVEL as Hierarchy_Level,
            src.[POSITION_REPORTS_TO] as Source_Found
        FROM #temp1 t1
            LEFT JOIN #temp2 t2 ON t1.POSITION_NBR_To_Check = t2.POSITION_NBR_To_Check
            LEFT JOIN [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] h ON t1.MANAGER_POSITION_NBR = h.POSITION_NBR
            LEFT JOIN (
        SELECT [POSITION_REPORTS_TO], COUNT(*) as Cnt
            FROM [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL]
            WHERE [LEVEL UP] = 1 AND NOTE <> 'missing in PS_JOB'
            GROUP BY [POSITION_REPORTS_TO]
    ) src ON t1.MANAGER_POSITION_NBR = src.[POSITION_REPORTS_TO]
        WHERE t1.MANAGER_POSITION_NBR = '40653963'
    )
SELECT
    Manager_Pos_Nbr,
    To_Trace_Up_1,
    Exists_In_Temp2,
    Hierarchy_Level,
    Source_Found,
    CASE
        WHEN Exists_In_Temp2 = 'Yes' THEN 'Position correctly processed through to temp2'
        WHEN To_Trace_Up_1 = 'no' THEN 'ISSUE: To_Trace_Up_1 must be ''yes'' for processing into temp2'
        WHEN Source_Found IS NULL THEN 'ISSUE: Position not found in UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL source table'
        WHEN To_Trace_Up_1 = 'yes' AND Source_Found IS NOT NULL THEN 'ISSUE: Position should exist in temp2 but doesn''t - check for data inconsistency'
        ELSE 'ISSUE: Unknown unexpected condition'
    END as Summary
FROM Diagnosis;

PRINT '=== END OF QA DIAGNOSIS ===';
PRINT '';
PRINT 'If this position is missing from temp2 due to data issues, consider updating:';
PRINT '1. [stage].[UKG_EMPL_HIERARCHY_POSN_LOOKUP] table to provide POSN_LEVEL for this position';
PRINT '2. [stage].[UKG_PositionReportsAnalysis_LEVEL_BY_LEVEL] table to include this position';
PRINT '3. Source data in [stage].[UKG_EMPL_Inactive_Manager] if related records are missing';