USE [HealthTime]
GO

/***************************************
* QA Analysis Script: SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT
* Investigation: Why emplid=10473712 is not inserted with NOTE='D'
* Created: 12/03/2025
* Purpose: Debug deletion logic in daily incremental history process
******************************************/

DECLARE @target_emplid VARCHAR(11) = '10473712';
DECLARE @today DATE = CAST(GETDATE() AS DATE);

PRINT '=== QA ANALYSIS FOR EMPLID: ' + @target_emplid + ' ===';
PRINT 'Analysis Date: ' + CAST(@today AS VARCHAR(20));
PRINT '';

-- Step 1: Check if employee exists in current UKG_EMPLOYEE_DATA table
PRINT '1. CHECKING CURRENT UKG_EMPLOYEE_DATA TABLE:';
IF EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE EMPLID = @target_emplid)
BEGIN
    PRINT '   ✓ Employee EXISTS in current UKG_EMPLOYEE_DATA';
    SELECT
        'Current Record' AS Status,
        EMPLID,
        [First Name] + ' ' + [Last Name] AS Employee_Name,
        hr_status,
        empl_Status,
        termination_dt,
        action,
        action_dt
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE EMPLID = @target_emplid;
END
ELSE
BEGIN
    PRINT '   ✗ Employee DOES NOT EXIST in current UKG_EMPLOYEE_DATA';
    PRINT '     This employee should be marked for deletion (NOTE=''D'')';
END

PRINT '';

-- Step 2: Check history table for this employee
PRINT '2. CHECKING UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY TABLE:';
IF EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @target_emplid)
BEGIN
    PRINT '   ✓ Employee EXISTS in history table';

    -- Show all history records for this employee
    SELECT
        'History Records' AS Status,
        EMPLID,
        [First Name] + ' ' + [Last Name] AS Employee_Name,
        hr_status,
        empl_Status,
        termination_dt,
        action,
        action_dt,
        hash_value,
        NOTE,
        snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    WHERE EMPLID = @target_emplid
    ORDER BY snapshot_date DESC, NOTE DESC;

    -- Check if deletion record already exists
    IF EXISTS (SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    WHERE EMPLID = @target_emplid AND NOTE = 'D')
    BEGIN
        PRINT '   ✓ Deletion record (NOTE=''D'') already exists for this employee';
    END
    ELSE
    BEGIN
        PRINT '   ✗ NO deletion record (NOTE=''D'') found for this employee';
    END
END
ELSE
BEGIN
    PRINT '   ✗ Employee DOES NOT EXIST in history table';
    PRINT '     Employee cannot be marked for deletion if never existed in history';
END

PRINT '';

-- Step 3: Simulate the MERGE source logic to see what would be generated
PRINT '3. SIMULATING MERGE SOURCE LOGIC FOR DELETIONS:';
PRINT '   Checking employees in history that are NOT in current UKG_EMPLOYEE_DATA...';

-- This is the exact logic from the MERGE source
WITH
    PotentialDeletions
    AS
    (
        SELECT
            EMPLID,
            [First Name] + ' ' + [Last Name] AS Employee_Name,
            hash_value,
            snapshot_date,
            NOTE AS Current_NOTE
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
        WHERE NOT EXISTS (
        SELECT 1
            FROM [dbo].[UKG_EMPLOYEE_DATA] src
            WHERE src.[EMPLID] = hist.[EMPLID]
    )
            AND hist.EMPLID = @target_emplid
    )
SELECT
    'Potential Deletion Source' AS Status,
    *
FROM PotentialDeletions;

-- Check if our target employee would be in the deletion source
IF EXISTS (
    SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
WHERE NOT EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE src.[EMPLID] = hist.[EMPLID]
    )
    AND hist.EMPLID = @target_emplid
)
BEGIN
    PRINT '   ✓ Employee would be included in deletion source';
END
ELSE
BEGIN
    PRINT '   ✗ Employee would NOT be included in deletion source';
    PRINT '     Reason: Either exists in current data OR not in history table';
END

PRINT '';

-- Step 4: Check MERGE target matching logic
PRINT '4. CHECKING MERGE TARGET MATCHING LOGIC:';
PRINT '   Analyzing why deletion record might not be inserted...';

-- Simulate the MERGE ON condition
WITH
    TargetMatches
    AS
    (
        SELECT
            target.EMPLID,
            target.hash_value AS target_hash,
            target.NOTE AS target_note,
            target.snapshot_date AS target_snapshot,
            source_data.hash_value AS source_hash,
            'D' AS source_note,
            @today AS source_snapshot
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] target
            INNER JOIN (
        -- This represents the MERGE source for deletions
        SELECT
                EMPLID,
                hash_value,
                'D' AS NOTE,
                @today AS snapshot_date
            FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
            WHERE NOT EXISTS (
            SELECT 1
                FROM [dbo].[UKG_EMPLOYEE_DATA] src
                WHERE src.[EMPLID] = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].[EMPLID]
        )
                AND EMPLID = @target_emplid
    ) source_data ON target.[EMPLID] = source_data.[EMPLID]
                AND target.[hash_value] = source_data.[hash_value]
                AND target.[NOTE] = source_data.[NOTE]
        WHERE target.EMPLID = @target_emplid
    )
SELECT
    'MERGE Match Analysis' AS Status,
    *
FROM TargetMatches;

-- Check for blocking conditions
IF EXISTS (
    SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] target
WHERE target.EMPLID = @target_emplid
    AND target.NOTE = 'D'
)
BEGIN
    PRINT '   ⚠️  BLOCKING CONDITION FOUND: Deletion record already exists';
    PRINT '     The MERGE ON condition would match existing deletion record';
    PRINT '     WHEN NOT MATCHED BY TARGET would not trigger';
END
ELSE
BEGIN
    PRINT '   ✓ No blocking deletion records found';
END

PRINT '';

-- Step 5: Manual simulation of what should happen
PRINT '5. MANUAL SIMULATION - WHAT SHOULD HAPPEN:';

-- Check if employee exists in current data
DECLARE @exists_in_current BIT = 0;
IF EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE EMPLID = @target_emplid)
    SET @exists_in_current = 1;

-- Check if employee exists in history
DECLARE @exists_in_history BIT = 0;
IF EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @target_emplid)
    SET @exists_in_history = 1;

-- Check if deletion record already exists
DECLARE @deletion_exists BIT = 0;
IF EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @target_emplid AND NOTE = 'D')
    SET @deletion_exists = 1;

PRINT '   Current Data Exists: ' + CASE WHEN @exists_in_current = 1 THEN 'YES' ELSE 'NO' END;
PRINT '   History Exists: ' + CASE WHEN @exists_in_history = 1 THEN 'YES' ELSE 'NO' END;
PRINT '   Deletion Record Exists: ' + CASE WHEN @deletion_exists = 1 THEN 'YES' ELSE 'NO' END;

IF @exists_in_current = 0 AND @exists_in_history = 1 AND @deletion_exists = 0
BEGIN
    PRINT '   ✓ SHOULD CREATE deletion record (NOTE=''D'')';
END
ELSE IF @exists_in_current = 1
BEGIN
    PRINT '   ✗ SHOULD NOT create deletion record - employee still active';
END
ELSE IF @exists_in_history = 0
BEGIN
    PRINT '   ✗ CANNOT create deletion record - employee never existed in history';
END
ELSE IF @deletion_exists = 1
BEGIN
    PRINT '   ✗ SHOULD NOT create deletion record - already exists';
END

PRINT '';

-- Step 6: Detailed hash analysis
PRINT '6. HASH VALUE ANALYSIS:';
PRINT '   Analyzing hash values that would be used in MERGE logic...';

-- Show all unique hash values for this employee in history
SELECT DISTINCT
    'History Hash Values' AS Status,
    EMPLID,
    hash_value,
    COUNT(*) AS record_count,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen,
    STUFF((SELECT DISTINCT ', ' + NOTE
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] sub
    WHERE sub.EMPLID = main.EMPLID AND sub.hash_value = main.hash_value
    FOR XML PATH('')), 1, 2, '') AS notes_used
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] main
WHERE EMPLID = @target_emplid
GROUP BY EMPLID, hash_value
ORDER BY MAX(snapshot_date) DESC;

-- Step 6A: Hash Value Comparison Analysis
PRINT '';
PRINT '6A. HASH VALUE COMPARISON - WHY MERGE FAILED:';
PRINT '   Comparing hash values between source and target for MERGE operation...';

-- Step 6A1: Calculate what the NEW hash would be if employee existed in current data
PRINT '';
PRINT '6A1. CURRENT DATA HASH CALCULATION:';
SELECT
    'Current Data Hash (if exists)' AS Analysis_Type,
    EMPLID,
    HASHBYTES('md5', CONCAT(
        EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
    )) AS current_hash_value,
    [First Name] + ' ' + [Last Name] AS Employee_Name,
    hr_status,
    empl_Status
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE emplid = @target_emplid;

-- If no current record, show what hash would be calculated
IF NOT EXISTS (SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE EMPLID = @target_emplid)
BEGIN
    PRINT '   ⚠️  Employee does NOT exist in current data - no new hash to calculate';
    PRINT '   The MERGE source uses EXISTING hash values from history table';
END

-- Step 6A2: Show what would be in the MERGE source (deletion candidates)
PRINT '';
PRINT '6A2. MERGE SOURCE ANALYSIS (What SP tries to insert):';
WITH
    MergeSource
    AS
    (
        SELECT DISTINCT
            hist.EMPLID,
            hist.hash_value AS source_hash_value,
            'D' AS NOTE,
            @today AS snapshot_date,
            hist.[First Name] + ' ' + hist.[Last Name] AS Employee_Name
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
        WHERE NOT EXISTS (
        SELECT 1
            FROM [dbo].[UKG_EMPLOYEE_DATA] src
            WHERE src.EMPLID = hist.EMPLID
    )
            AND hist.EMPLID = @target_emplid
    )
SELECT
    'MERGE Source (What SP would try to insert)' AS Analysis_Type,
    EMPLID,
    source_hash_value,
    NOTE,
    snapshot_date,
    Employee_Name
FROM MergeSource;

-- Show what exists in target that would block insertion
PRINT '';
PRINT '6A3. MERGE TARGET ANALYSIS (Existing records that could block):';
SELECT
    'MERGE Target (Existing records that could block)' AS Analysis_Type,
    EMPLID,
    hash_value AS target_hash_value,
    NOTE,
    snapshot_date,
    [First Name] + ' ' + [Last Name] AS Employee_Name
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @target_emplid
ORDER BY snapshot_date DESC;

-- Critical Analysis: Check for exact MERGE matches
PRINT '';
PRINT '6A4. CRITICAL MERGE MATCH ANALYSIS:';
PRINT '   Checking if any SOURCE hash matches any TARGET hash with NOTE=''D''...';

WITH
    MergeSource
    AS
    (
        SELECT DISTINCT
            hist.EMPLID,
            hist.hash_value AS source_hash,
            'D' AS NOTE
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
        WHERE NOT EXISTS (
        SELECT 1
            FROM [dbo].[UKG_EMPLOYEE_DATA] src
            WHERE src.EMPLID = hist.EMPLID
    )
            AND hist.EMPLID = @target_emplid
    ),
    ExactMatches
    AS
    (
        SELECT
            target.EMPLID,
            target.hash_value AS target_hash,
            source.source_hash,
            target.NOTE AS target_note,
            source.NOTE AS source_note,
            'EXACT MATCH FOUND - BLOCKS INSERT' AS block_reason
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] target
            INNER JOIN MergeSource source ON target.EMPLID = source.EMPLID
                AND target.hash_value = source.source_hash
                AND target.NOTE = source.NOTE
    )
SELECT
    'MERGE Blocking Analysis' AS Analysis_Type,
    EMPLID,
    target_hash,
    source_hash,
    target_note,
    source_note,
    block_reason
FROM ExactMatches;

-- Summary of blocking condition
PRINT '';
PRINT '6A5. BLOCKING CONDITION SUMMARY:';
IF EXISTS (
    SELECT 1
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] target
WHERE target.EMPLID = @target_emplid
    AND target.NOTE = 'D'
    AND target.hash_value IN (
        SELECT DISTINCT hist.hash_value
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
    WHERE NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA] src
        WHERE src.EMPLID = hist.EMPLID
        )
        AND hist.EMPLID = @target_emplid
    )
)
BEGIN
    PRINT '   ❌ BLOCKING CONDITION: Exact hash + NOTE=''D'' match found';
    PRINT '      MERGE ON condition matches existing record';
    PRINT '      WHEN NOT MATCHED BY TARGET will NOT execute';
    PRINT '';
    PRINT '   EXPLANATION:';
    PRINT '   - MERGE source tries to insert deletion records using existing hash values';
    PRINT '   - TARGET already has deletion record(s) with same hash value(s)';
    PRINT '   - MERGE ON condition: EMPLID + hash_value + NOTE = ''D'' matches';
    PRINT '   - Therefore WHEN NOT MATCHED BY TARGET does not execute';
END
ELSE
BEGIN
    PRINT '   ✓ No exact blocking matches found';
    PRINT '   ⚠️  If SP still didn''t insert, check other issues:';
    PRINT '      - Transaction errors';
    PRINT '      - Permission issues';
    PRINT '      - Data type mismatches';
    PRINT '      - SP logic errors';
END

PRINT '';

-- Step 7: Recommendations
PRINT '7. RECOMMENDATIONS:';
PRINT '';
IF @exists_in_current = 0 AND @exists_in_history = 1 AND @deletion_exists = 0
BEGIN
    PRINT '   RECOMMENDATION: Employee should have deletion record created';
    PRINT '   ACTION: Run the stored procedure - it should create NOTE=''D'' record';
    PRINT '   If it doesn''t work, check for:';
    PRINT '     - Duplicate hash values preventing MERGE';
    PRINT '     - Timing issues with @today date matching';
    PRINT '     - Transaction rollbacks or errors';
END
ELSE IF @deletion_exists = 1
BEGIN
    PRINT '   RECOMMENDATION: No action needed - deletion already recorded';
END
ELSE IF @exists_in_current = 1
BEGIN
    PRINT '   RECOMMENDATION: No deletion needed - employee is still active';
END
ELSE
BEGIN
    PRINT '   RECOMMENDATION: Check data integrity - unusual state detected';
END

PRINT '';
PRINT '=== END QA ANALYSIS ===';
