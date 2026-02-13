USE [HealthTime]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  Script Name:    QA_UKG_HR_STATUS_LOOKUP_10000644.sql
--  Author:         Jim Shih
--  Version:        1.0
--  Date:           9/6/2025
--  Description:    Quality Assurance query to trace records AFTER a change to the MOST RECENT HR_STATUS for EMPLID=10000644
--                  This query breaks down the stored procedure logic step by step to show:
--                  1. All raw records from ps_job for this employee with detailed filter status explanations
--                  2. Records after initial filtering with explanations of why they passed all filters
--                  3. StatusChanges CTE with LAG function results, highlighting HR_STATUS changes
--                  4. ActualChangePoints CTE showing HR status changes, focusing on records after HR_STATUS changes
--                  5. Records that occur AFTER the MOST RECENT HR_STATUS change (latest HR status adjustment)
--                  6. Final result with UNION logic explanations showing why each record was selected
--                  Each step includes detailed explanations focusing on the most recent HR_STATUS change impacts
--  Parameters:     EMPLID = '10000644'
--  Usage:          Execute entire script to see step-by-step breakdown
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

DECLARE @EMPLID VARCHAR(11) = '10000644';

PRINT '=== QA ANALYSIS FOR EMPLID: ' + @EMPLID + ' ===';
PRINT 'Current Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';

-- Step 1: Show ALL raw records from ps_job for this employee
PRINT '=== STEP 1: ALL RAW RECORDS FROM ps_job ===';
SELECT
    emplid,
    HR_STATUS,
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
    HR_STATUS,
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
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            -- Show the LAG function result
            LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS,
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
    HR_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_HR_STATUS,
    previous_HIRE_DT,
    RowNum_Oldest,
    CASE 
        WHEN HR_STATUS <> previous_HR_STATUS THEN 'HR STATUS CHANGE DETECTED'
        ELSE 'No HR Status Change'
    END AS CHANGE_INDICATOR,
    CASE 
        WHEN RowNum_Oldest = 1 THEN 'OLDEST RECORD: First chronological record for employee'
        WHEN HIRE_DT <> previous_HIRE_DT THEN 'AFTER HIRE_DT CHANGE: Record after HIRE_DT changed from [' + CONVERT(VARCHAR, previous_HIRE_DT, 101) + '] to [' + CONVERT(VARCHAR, HIRE_DT, 101) + '] *** POST-HIRE-DATE-CHANGE ***'
        WHEN HR_STATUS <> previous_HR_STATUS THEN 'HR STATUS CHANGE: Status changed from [' + ISNULL(previous_HR_STATUS, 'NULL') + '] to [' + ISNULL(HR_STATUS, 'NULL') + ']'
        ELSE 'CONTINUATION: Same HR status [' + ISNULL(HR_STATUS, 'NULL') + '] and HIRE_DT [' + CONVERT(VARCHAR, HIRE_DT, 101) + ']'
    END AS LOGIC_EXPLANATION,
    'StatusChanges CTE' AS RECORD_TYPE
FROM StatusChanges
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 4: ActualChangePoints CTE (HR Status Changes Only) ===';

-- Step 4: Show ActualChangePoints CTE results
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS,
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
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HR_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
        FROM StatusChanges
        WHERE HR_STATUS <> previous_HR_STATUS
    )
SELECT
    emplid,
    HR_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_HR_STATUS,
    rn_of_change,
    CASE WHEN rn_of_change = 1 THEN 'LATEST CHANGE' ELSE 'Earlier Change' END AS CHANGE_RANK,
    CASE 
        WHEN rn_of_change = 1 THEN 'SELECTED: Most recent HR status change from [' + ISNULL(previous_HR_STATUS, 'NULL') + '] to [' + ISNULL(HR_STATUS, 'NULL') + '] on ' + CONVERT(VARCHAR, EFFDT, 101)
        ELSE 'NOT SELECTED: Earlier HR status change from [' + ISNULL(previous_HR_STATUS, 'NULL') + '] to [' + ISNULL(HR_STATUS, 'NULL') + '] on ' + CONVERT(VARCHAR, EFFDT, 101)
    END AS SELECTION_LOGIC,
    'ActualChangePoints CTE' AS RECORD_TYPE
FROM ActualChangePoints
ORDER BY rn_of_change ASC;

PRINT '';
PRINT '=== STEP 4A: RECORDS AFTER MOST RECENT HR_STATUS CHANGE ===';

-- Step 4A: Show records that occur AFTER the MOST RECENT change in HR_STATUS
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ),
    AllHRStatusChanges
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HIRE_DT,
            previous_HR_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS hr_status_change_rank
        FROM StatusChanges
        WHERE HR_STATUS <> previous_HR_STATUS
            AND previous_HR_STATUS IS NOT NULL
    ),
    MostRecentHRStatusChange
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HIRE_DT,
            previous_HR_STATUS,
            'MOST RECENT HR_STATUS CHANGE: Latest adjustment from ' + CONVERT(VARCHAR, previous_HR_STATUS, 101) + ' to ' + CONVERT(VARCHAR, HR_STATUS, 101) + ' (Most Recent: ' + CONVERT(VARCHAR, HR_STATUS, 101) + ')' AS MOST_RECENT_HR_STATUS_EXPLANATION
        FROM AllHRStatusChanges
        WHERE hr_status_change_rank = 1
    )
SELECT
    emplid,
    HR_STATUS,
    EFFDT,
    EFFSEQ,
    EMPL_RCD,
    HIRE_DT,
    previous_HIRE_DT,
    previous_HR_STATUS,
    MOST_RECENT_HR_STATUS_EXPLANATION,
    'Record After MOST RECENT HR_STATUS Change' AS RECORD_TYPE,
    CASE
        WHEN HR_STATUS <> previous_HR_STATUS THEN 'MOST RECENT HR_STATUS changed from [' + ISNULL(previous_HR_STATUS, 'NULL') + '] to [' + ISNULL(HR_STATUS, 'NULL') + '] AND hire date is [' + CONVERT(VARCHAR, HIRE_DT, 101) + ']'
        ELSE 'MOST RECENT HR_STATUS changed from [' + ISNULL(previous_HR_STATUS, 'NULL') + '] to [' + ISNULL(HR_STATUS, 'NULL') + '] with hire date [' + CONVERT(VARCHAR, HIRE_DT, 101) + ']'
    END AS LATEST_HR_STATUS_IMPACT_ANALYSIS,
    'This record represents the employee data immediately after the most recent HR status adjustment' AS SIGNIFICANCE
FROM MostRecentHRStatusChange
ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC;

PRINT '';
PRINT '=== STEP 5: FINAL RESULT (What gets inserted into UKG_HR_STATUS_LOOKUP) ===';

-- Step 5: Show final result that would be inserted
WITH
    StatusChanges
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS,
            LAG(HIRE_DT) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HIRE_DT,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS RowNum_Oldest
        FROM health_ods.[health_ods].[stable].ps_job
        WHERE emplid = @EMPLID
            AND EFFDT <= GETDATE()
            AND DML_IND <> 'D'
            AND JOB_INDICATOR='P'
            AND EFFDT >= HIRE_DT
    ),
    HRStatusChanges
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HIRE_DT,
            previous_HR_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS hr_status_change_rank
        FROM StatusChanges
        WHERE HR_STATUS <> previous_HR_STATUS AND previous_HR_STATUS IS NOT NULL
    ),
    ActualChangePoints
    AS
    (
        SELECT
            emplid,
            HR_STATUS,
            EFFDT,
            EFFSEQ,
            EMPL_RCD,
            HIRE_DT,
            previous_HR_STATUS,
            ROW_NUMBER() OVER (PARTITION BY emplid ORDER BY EFFDT DESC, EFFSEQ DESC, EMPL_RCD DESC) AS rn_of_change
        FROM StatusChanges
        WHERE HR_STATUS <> previous_HR_STATUS
    ),
    OldestRecordsCTE
    AS
    (
        SELECT
            sc.emplid,
            sc.HR_STATUS,
            sc.EFFDT,
            sc.EFFSEQ,
            sc.EMPL_RCD,
            sc.HIRE_DT,
            'Oldest Record' AS NOTE
        FROM StatusChanges sc
        WHERE sc.RowNum_Oldest = 1
    ),
    MostRecentHRStatusChangeRecordsCTE
    AS
    (
        SELECT
            hrsc.emplid,
            hrsc.HR_STATUS,
            hrsc.EFFDT,
            hrsc.EFFSEQ,
            hrsc.EMPL_RCD,
            hrsc.HIRE_DT,
            'After Most Recent HR_STATUS Change' AS NOTE
        FROM HRStatusChanges hrsc
        WHERE hrsc.hr_status_change_rank = 1
    ),
    LatestChangeRecordsCTE
    AS
    (
        SELECT
            acp.emplid,
            acp.HR_STATUS,
            acp.EFFDT,
            acp.EFFSEQ,
            acp.EMPL_RCD,
            acp.HIRE_DT,
            'Latest HR Status Change' AS NOTE
        FROM ActualChangePoints acp
        WHERE acp.rn_of_change = 1
    )
SELECT
    UnionData.emplid,
    UnionData.HR_STATUS,
    UnionData.EFFDT,
    UnionData.EFFSEQ,
    UnionData.EMPL_RCD,
    UnionData.HIRE_DT,
    UnionData.NOTE,
    GETDATE() AS LOAD_DTTM,
    CASE 
        WHEN UnionData.NOTE = 'After Most Recent HR_STATUS Change' THEN 'UNION LOGIC: Record after most recent HR_STATUS change - highest priority'
        WHEN UnionData.NOTE = 'Latest HR Status Change' THEN 'UNION LOGIC: Latest HR status change exists - using most recent change point'
        WHEN UnionData.NOTE = 'Oldest Record' THEN 'UNION LOGIC: No HR status changes exist - using oldest (first hire) record as default'
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
        -- Priority 1: Records after MOST RECENT HR_STATUS change (highest priority)
                    SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
        FROM MostRecentHRStatusChangeRecordsCTE

    UNION ALL

        -- Priority 2: Latest HR_STATUS change (when no HR_STATUS changes exist)
        SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
        FROM LatestChangeRecordsCTE
        WHERE emplid NOT IN (SELECT EMPLID
        FROM MostRecentHRStatusChangeRecordsCTE)

    UNION ALL

        -- Priority 3: Oldest record (fallback when no changes exist)
        SELECT emplid, HR_STATUS, EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT, NOTE
        FROM OldestRecordsCTE
        WHERE emplid NOT IN (SELECT EMPLID
            FROM MostRecentHRStatusChangeRecordsCTE)
            AND emplid NOT IN (SELECT EMPLID
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
        'HR Status Change Points' AS METRIC,
        COUNT(*) AS COUNT
    FROM (
    SELECT emplid
        FROM (
        SELECT
                emplid,
                HR_STATUS,
                LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS
            FROM health_ods.[health_ods].[stable].ps_job
            WHERE emplid = @EMPLID
                AND EFFDT <= GETDATE()
                AND DML_IND <> 'D'
                AND JOB_INDICATOR='P'
                AND EFFDT >= HIRE_DT
    ) sc
        WHERE HR_STATUS <> previous_HR_STATUS
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
        'Final Records in HR Status Lookup Table' AS METRIC,
        CASE WHEN EXISTS (
        SELECT 1
        FROM (
            SELECT emplid
            FROM (
                SELECT
                    emplid,
                    HR_STATUS,
                    LAG(HR_STATUS, 1, HR_STATUS) OVER (PARTITION BY emplid ORDER BY EFFDT ASC, EFFSEQ ASC, EMPL_RCD ASC) AS previous_HR_STATUS
                FROM health_ods.[health_ods].[stable].ps_job
                WHERE emplid = @EMPLID
                    AND EFFDT <= GETDATE()
                    AND DML_IND <> 'D'
                    AND JOB_INDICATOR='P'
                    AND EFFDT >= HIRE_DT
            ) sc
            WHERE HR_STATUS <> previous_HR_STATUS
        ) changes
    ) THEN 1 ELSE 1 END AS COUNT;
-- Will be 1 if changes exist (Latest Change), 1 if no changes (Oldest Record only)

PRINT '';
PRINT '=== LOGIC EXPLANATION - FOCUS ON MOST RECENT HR_STATUS CHANGES ===';
PRINT 'The stored procedure logic works as follows:';
PRINT '1. Filter records: EFFDT <= Current Date, Not Deleted, Primary Job, EFFDT >= HIRE_DT';
PRINT '2. CRITICAL FILTER: EFFDT >= HIRE_DT ensures records are not before hire date';
PRINT '3. Use LAG function to identify HR status changes between consecutive records';
PRINT '4. SPECIAL FOCUS: Identify records that occur AFTER the MOST RECENT HR_STATUS change';
PRINT '5. MULTIPLE HR_STATUS SCENARIO: When several HR_STATUS changes exist, focus on the latest one';
PRINT '6. PRIORITY 1: Records after most recent HR_STATUS change (highest priority)';
PRINT '7. PRIORITY 2: If no HR_STATUS changes exist, return the LATEST HR status change record';
PRINT '8. PRIORITY 3: If NO HR status changes exist, return the OLDEST record (first hire status)';
PRINT '9. HR_STATUS IMPACT: Changes in HR_STATUS reflect the most current employment status';
PRINT '10. MOST RECENT HR_STATUS: Latest HR status adjustment has the greatest impact on current data';
PRINT '11. POST-MOST-RECENT-HR-STATUS-CHANGE: Records after latest HR status adjustment represent current state';
PRINT '12. This ensures accuracy by capturing the most recent HR status changes for each employee';
