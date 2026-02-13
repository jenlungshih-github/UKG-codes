USE [HealthTime]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  Script Name:    QA_UKG_EMPL_STATUS_LOOKUP_10361877.sql
--  Author:         Jim Shih
--  Version:        1.0
--  Date:           9/5/2025
--  Description:    Quality Assurance query to trace records AFTER a change to the MOST RECENT HIRE_DT for EMPLID=10361877
--                  This query breaks down the stored procedure logic step by step to show:
--                  1. All raw records from ps_job for this employee with detailed filter status explanations
--                  2. Records after initial filtering with explanations of why they passed all filters
--                  3. StatusChanges CTE with LAG function results, highlighting HIRE_DT changes
--                  4. ActualChangePoints CTE showing status changes, focusing on records after HIRE_DT changes
--                  5. Records that occur AFTER the MOST RECENT HIRE_DT change (latest hire date adjustment)
--                  6. Final result with UNION logic explanations showing why each record was selected
--                  Each step includes detailed explanations focusing on the most recent HIRE_DT change impacts
--  Parameters:     EMPLID = '10361877'
--  Usage:          Execute entire script to see step-by-step breakdown
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

DECLARE @EMPLID VARCHAR(11) = '10361877';

PRINT '=== QA ANALYSIS FOR EMPLID: ' + @EMPLID + ' ===';
PRINT 'Current Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

-- Step 1: Show ALL raw records from ps_job for this employee
PRINT '=== STEP 1: ALL RAW RECORDS FROM ps_job ===';
SELECT
    emplid,
    EMPL_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    DML_IND,
    JOB_INDICATOR,
    'Raw Record' AS RECORD_TYPE,
    CASE 
        WHEN EFFDT > GETDATE() THEN 'Future Date - EXCLUDED'
        WHEN DML_IND = 'D' THEN 'Deleted Record - EXCLUDED'
        WHEN JOB_INDICATOR <> 'P' THEN 'Not Primary Job - EXCLUDED'
        WHEN EFFDT < HIRE_DT THEN 'EFFDT Before HIRE_DT - EXCLUDED (EFFDT: ' + CONVERT(VARCHAR, EFFDT, 101) + ' < HIRE_DT: ' + CONVERT(VARCHAR, HIRE_DT, 101) + ')'
        ELSE 'INCLUDED in Analysis'
    END AS FILTER_STATUS,
    LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
    CASE 
        WHEN LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) IS NULL THEN 'First Record'
        WHEN HIRE_DT <> LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) THEN 'HIRE_DT CHANGED from ' + CONVERT(VARCHAR, LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC), 101) + ' to ' + CONVERT(VARCHAR, HIRE_DT, 101)
        ELSE 'Same HIRE_DT'
    END AS HIRE_DT_CHANGE_STATUS
FROM health_ods.[health_ods].[stable].ps_job
WHERE emplid = @EMPLID
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 2: FILTERED RECORDS (After Initial Filtering) ===';

-- Step 2: Show records after initial filtering
SELECT
    emplid,
    EMPL_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    DML_IND,
    JOB_INDICATOR,
    'Filtered Record' AS RECORD_TYPE,
    CASE 
        WHEN EFFDT <= GETDATE() AND DML_IND <> 'D' AND JOB_INDICATOR='P' AND EFFDT >= HIRE_DT 
        THEN 'PASSED ALL FILTERS: EFFDT <= Current Date (' + CONVERT(VARCHAR, GETDATE(), 101) + '), Not Deleted (DML_IND=' + ISNULL(DML_IND, 'NULL') + '), Primary Job (JOB_INDICATOR=' + ISNULL(JOB_INDICATOR, 'NULL') + '), EFFDT >= HIRE_DT (' + CONVERT(VARCHAR, HIRE_DT, 101) + ')'
        ELSE 'SHOULD NOT APPEAR - Filter Logic Error'
    END AS FILTER_EXPLANATION
FROM health_ods.[health_ods].[stable].ps_job
WHERE emplid = @EMPLID
    AND EFFDT <= GETDATE() -- Consider records up to the current date
    AND DML_IND <> 'D' -- Exclude deleted records
    AND JOB_INDICATOR='P' -- Primary job indicator
    AND EFFDT >= HIRE_DT
-- Ensure effective date is not before hire date
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 3: StatusChanges CTE (With LAG Function Results) ===';

-- Step 3: Replicate StatusChanges CTE to show LAG function results
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            -- Show the LAG function result
            LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
            -- Rank records for each employee by effective date, oldest first
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    )
SELECT
    emplid,
    EMPL_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_EMPL_STATUS,
    previous_HIRE_DT,
    RowNum_Oldest,
    CASE 
        WHEN EMPL_STATUS <> previous_EMPL_STATUS THEN 'STATUS CHANGE DETECTED'
        ELSE 'No Status Change'
    END AS CHANGE_INDICATOR,
    CASE 
        WHEN RowNum_Oldest = 1 THEN 'OLDEST RECORD: First chronological record for employee'
        WHEN HIRE_DT <> previous_HIRE_DT THEN 'AFTER HIRE_DT CHANGE: Record after HIRE_DT changed from [' + CONVERT(VARCHAR, previous_HIRE_DT, 101) + '] to [' + CONVERT(VARCHAR, HIRE_DT, 101) + '] *** POST-HIRE-DATE-CHANGE ***'
        WHEN EMPL_STATUS <> previous_EMPL_STATUS THEN 'STATUS CHANGE: Status changed from [' + ISNULL(previous_EMPL_STATUS, 'NULL') + '] to [' + ISNULL(EMPL_STATUS, 'NULL') + ']'
        ELSE 'CONTINUATION: Same status [' + ISNULL(EMPL_STATUS, 'NULL') + '] and HIRE_DT [' + CONVERT(VARCHAR, HIRE_DT, 101) + ']'
    END AS LOGIC_EXPLANATION,
    'StatusChanges CTE' AS RECORD_TYPE
FROM StatusChanges
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 4: ActualChangePoints CTE (Status Changes Only) ===';

-- Step 4: Show ActualChangePoints CTE results
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ),
    ActualChangePoints
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_EMPL_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
        FROM StatusChanges
        WHERE EMPL_STATUS <> previous_EMPL_STATUS
    )
SELECT
    emplid,
    EMPL_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_EMPL_STATUS,
    rn_of_change,
    CASE WHEN rn_of_change = 1 THEN 'LATEST CHANGE' ELSE 'Earlier Change' END AS CHANGE_RANK,
    CASE 
        WHEN rn_of_change = 1 THEN 'SELECTED: Most recent status change from [' + ISNULL(previous_EMPL_STATUS, 'NULL') + '] to [' + ISNULL(EMPL_STATUS, 'NULL') + '] on ' + CONVERT(VARCHAR, EFFDT, 101)
        ELSE 'NOT SELECTED: Earlier status change from [' + ISNULL(previous_EMPL_STATUS, 'NULL') + '] to [' + ISNULL(EMPL_STATUS, 'NULL') + '] on ' + CONVERT(VARCHAR, EFFDT, 101)
    END AS SELECTION_LOGIC,
    'ActualChangePoints CTE' AS RECORD_TYPE
FROM ActualChangePoints
ORDER BY rn_of_change ASC;

PRINT '';
PRINT '=== STEP 4A: RECORDS AFTER MOST RECENT HIRE_DT CHANGE ===';

-- Step 4A: Show records that occur AFTER the MOST RECENT change in HIRE_DT
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ),
    AllHireDateChanges
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HIRE_DT,
            previous_EMPL_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS hire_change_rank
        FROM StatusChanges
        WHERE HIRE_DT <> previous_HIRE_DT
            AND previous_HIRE_DT IS NOT NULL
    ),
    MostRecentHireDateChange
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HIRE_DT,
            previous_EMPL_STATUS,
            'MOST RECENT HIRE_DT CHANGE: Latest adjustment from ' + CONVERT(VARCHAR, previous_HIRE_DT, 101) + ' to ' + CONVERT(VARCHAR, HIRE_DT, 101) + ' (Most Recent: ' + CONVERT(VARCHAR, HIRE_DT, 101) + ')' AS MOST_RECENT_HIRE_DATE_EXPLANATION
        FROM AllHireDateChanges
        WHERE hire_change_rank = 1
    )
SELECT
    emplid,
    EMPL_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_HIRE_DT,
    previous_EMPL_STATUS,
    MOST_RECENT_HIRE_DATE_EXPLANATION,
    'Record After MOST RECENT HIRE_DT Change' AS RECORD_TYPE,
    CASE
        WHEN EMPL_STATUS <> previous_EMPL_STATUS THEN 'MOST RECENT HIRE_DT changed from [' + CONVERT(VARCHAR, previous_HIRE_DT, 101) + '] to [' + CONVERT(VARCHAR, HIRE_DT, 101) + '] AND status changed from [' + ISNULL(previous_EMPL_STATUS, 'NULL') + '] to [' + ISNULL(EMPL_STATUS, 'NULL') + ']'
        ELSE 'MOST RECENT HIRE_DT changed from [' + CONVERT(VARCHAR, previous_HIRE_DT, 101) + '] to [' + CONVERT(VARCHAR, HIRE_DT, 101) + '] but status remained [' + ISNULL(EMPL_STATUS, 'NULL') + ']'
    END AS LATEST_HIRE_DT_IMPACT_ANALYSIS,
    'This record represents the employee data immediately after the most recent hire date adjustment' AS SIGNIFICANCE
FROM MostRecentHireDateChange
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 5: FINAL RESULT (What gets inserted into UKG_EMPL_STATUS_LOOKUP) ===';

-- Step 5: Show final result that would be inserted
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ),
    ActualChangePoints
    AS
    (
        SELECT
            emplid,
            EMPL_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_EMPL_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
        FROM StatusChanges
        WHERE EMPL_STATUS <> previous_EMPL_STATUS
    ),
    OldestRecordsCTE
    AS
    (
        SELECT
            sc.emplid,
            sc.EMPL_STATUS,
            sc.EFFDT,
            sc.EFFSEQ,
            sc.EMPL_RCD,
            sc.HIRE_DT,
            'Oldest Record' AS NOTE
        FROM StatusChanges sc
        WHERE sc.RowNum_Oldest = 1
    ),
    LatestChangeRecordsCTE
    AS
    (
        SELECT
            acp.emplid,
            acp.EMPL_STATUS,
            acp.EFFDT,
            acp.EFFSEQ,
            acp.EMPL_RCD,
            acp.HIRE_DT,
            'Latest Change' AS NOTE
        FROM ActualChangePoints acp
        WHERE acp.rn_of_change = 1
    )
SELECT
    UnionData.emplid,
    UnionData.EMPL_STATUS,
    UnionData.EFFDT,
    UnionData.EFFSEQ,
    UnionData.EMPL_RCD,
    UnionData.HIRE_DT,
    UnionData.NOTE,
    GETDATE() AS LOAD_DTTM,
    CASE 
        WHEN UnionData.NOTE = 'Latest Change' THEN 'UNION LOGIC: Latest status change exists - using most recent change point'
        WHEN UnionData.NOTE = 'Oldest Record' THEN 'UNION LOGIC: No status changes exist - using oldest (first hire) record as default'
        ELSE 'Unknown NOTE value'
    END AS UNION_EXPLANATION,
    CASE
        WHEN EXISTS (
            -- Check if this record follows the most recent HIRE_DT change
            SELECT 1
    FROM (
                SELECT
            EFFDT, EFFSEQ, EMPL_RCD,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS prev_hire_dt,
            HIRE_DT,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS recent_change_rank
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE() AND DML_IND <> 'D' AND JOB_INDICATOR='P' AND EFFDT >= HIRE_DT
            ) all_records
    WHERE all_records.HIRE_DT <> all_records.prev_hire_dt
        AND all_records.prev_hire_dt IS NOT NULL
        AND all_records.recent_change_rank = 1
        AND all_records.EFFDT = UnionData.EFFDT
        AND all_records.EFFSEQ = UnionData.EFFSEQ
        AND all_records.EMPL_RCD = UnionData.EMPL_RCD
        ) THEN 'MOST RECENT HIRE_DT IMPACT: This record follows the MOST RECENT HIRE_DT change - latest hire date adjustment'
        WHEN EXISTS (
            SELECT 1
    FROM (
                SELECT
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS prev_hire_dt,
            HIRE_DT
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT = UnionData.EFFDT
            AND EFFSEQ = UnionData.EFFSEQ
            AND EMPL_RCD = UnionData.EMPL_RCD
            AND EFFDT <= GETDATE() AND DML_IND <> 'D' AND JOB_INDICATOR='P' AND EFFDT >= HIRE_DT
            ) chk
    WHERE chk.HIRE_DT <> chk.prev_hire_dt AND chk.prev_hire_dt IS NOT NULL
        ) THEN 'HIRE_DT IMPACT: This record follows an earlier HIRE_DT change - not the most recent'
        ELSE 'HIRE_DT IMPACT: No HIRE_DT change detected for this record'
    END AS HIRE_DT_IMPACT_ANALYSIS,
    'FINAL RESULT' AS RECORD_TYPE
FROM
    (
                        SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
        FROM LatestChangeRecordsCTE
    UNION ALL
        SELECT emplid, EMPL_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
        FROM OldestRecordsCTE
        WHERE emplid NOT IN (SELECT EMPLID
        FROM LatestChangeRecordsCTE)
)
AS UnionData
ORDER BY NOTE DESC;
-- Latest Change first, then Oldest Record

PRINT '';
PRINT '=== SUMMARY ANALYSIS ===';

-- Summary counts for verification
    SELECT
        'Total Raw Records' AS METRIC,
        COUNT(*) AS COUNT
    FROM health_ods.[health_ods].[stable].ps_job
    WHERE emplid = @EMPLID

UNION ALL

    SELECT
        'Records After Filtering' AS METRIC,
        COUNT(*) AS COUNT
    FROM health_ods.[health_ods].[stable].ps_job
    WHERE emplid = @EMPLID
        AND EFFDT <= GETDATE()
        AND DML_IND <> 'D'
        AND JOB_INDICATOR='P'
        AND EFFDT >= HIRE_DT

UNION ALL

    SELECT
        'Status Change Points' AS METRIC,
        COUNT(*) AS COUNT
    FROM (
    SELECT emplid
        FROM (
        SELECT
                emplid,
                EMPL_STATUS,
                LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS
            FROM health_ods.[health_ods].[stable].ps_job
            WHERE emplid = @EMPLID
                AND EFFDT <= GETDATE()
                AND DML_IND <> 'D'
                AND JOB_INDICATOR='P'
                AND EFFDT >= HIRE_DT
    ) sc
        WHERE EMPL_STATUS <> previous_EMPL_STATUS
) changes

UNION ALL

    SELECT
        'HIRE_DT Change Points' AS METRIC,
        COUNT(*) AS COUNT
    FROM (
    SELECT emplid
        FROM (
        SELECT
                emplid,
                HIRE_DT,
                LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT
            FROM health_ods.[health_ods].[stable].ps_job
            WHERE emplid = @EMPLID
                AND EFFDT <= GETDATE()
                AND DML_IND <> 'D'
                AND JOB_INDICATOR='P'
                AND EFFDT >= HIRE_DT
    ) sc
        WHERE HIRE_DT <> previous_HIRE_DT AND previous_HIRE_DT IS NOT NULL
) hire_dt_changes

UNION ALL

    SELECT
        'Most Recent HIRE_DT: ' + CONVERT(VARCHAR, MAX(HIRE_DT), 101) AS METRIC,
        1 AS COUNT
    FROM (
        SELECT DISTINCT HIRE_DT
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ) all_hire_dates

UNION ALL

    SELECT
        'Final Records in Lookup Table' AS METRIC,
        CASE WHEN EXISTS (
        SELECT 1
        FROM (
            SELECT emplid
            FROM (
                SELECT
                    emplid,
                    EMPL_STATUS,
                    LAG(EMPL_STATUS, 1, EMPL_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_EMPL_STATUS
                FROM health_ods.[health_ods].[stable].ps_job
                WHERE emplid = @EMPLID
                    AND EFFDT <= GETDATE()
                    AND DML_IND <> 'D'
                    AND JOB_INDICATOR='P'
                    AND EFFDT >= HIRE_DT
            ) sc
            WHERE EMPL_STATUS <> previous_EMPL_STATUS
        ) changes
    ) THEN 1 ELSE 1 END AS COUNT;
-- Will be 1 if changes exist (Latest Change), 1 if no changes (Oldest Record only)

PRINT '';
PRINT '=== LOGIC EXPLANATION - FOCUS ON MOST RECENT HIRE_DT CHANGES ===';
PRINT 'The stored procedure logic works as follows:';
PRINT '1. Filter records: EFFDT <= Current Date, Not Deleted, Primary Job, EFFDT >= HIRE_DT';
PRINT '2. CRITICAL FILTER: EFFDT >= HIRE_DT ensures records are not before hire date';
PRINT '3. Use LAG function to identify status changes between consecutive records';
PRINT '4. SPECIAL FOCUS: Identify records that occur AFTER the MOST RECENT HIRE_DT change';
PRINT '5. MULTIPLE HIRE_DT SCENARIO: When several HIRE_DT changes exist, focus on the latest one';
PRINT '6. If status changes exist: Return the LATEST status change record';
PRINT '7. If NO status changes exist: Return the OLDEST record (first hire status)';
PRINT '8. HIRE_DT IMPACT: Changes in HIRE_DT can affect which records pass the EFFDT >= HIRE_DT filter';
PRINT '9. MOST RECENT HIRE_DT: Latest hire date adjustment has the greatest impact on current data integrity';
PRINT '10. POST-MOST-RECENT-HIRE-DATE-CHANGE: Records after latest HIRE_DT adjustment represent current state';
PRINT '11. This ensures data integrity by preventing records with effective dates before the most recent hire date';
