USE [Health_ODS]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  QA Query for: Position Data Analysis (based on 25.sql)
--  Target POSITION_NBR: 40882509
--  Author:         Jim Shih
--  Date:           10/29/2025
--  Description:    This QA query breaks down the position data query logic step by step 
--                  to validate the filtering and join logic for a specific position number.
--                  
--  Steps:
--  1. Check base position data (all records)
--  2. Apply EFF_STATUS = 'A' filter
--  3. Apply BUSINESS_UNIT filter
--  4. Apply DML_IND filter
--  5. Apply MAX EFFDT filter (final result)
--  6. Show job code lookup logic
--  7. Show department hierarchy lookup
--  8. Compare with final query results
--
--  Usage:          Run this entire script to get comprehensive QA results
***************************************************************************************************************************************************************************************************************************************************************/

DECLARE @POSITION_NBR VARCHAR(20) = '40882509';

PRINT '=== QA ANALYSIS FOR POSITION: ' + @POSITION_NBR + ' ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
PRINT ''

-- Step 1: Check all position records (before any filtering)
PRINT '=== STEP 1: ALL POSITION RECORDS (Before Filtering) ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.DESCR,
    POSN.DML_IND,
    'Raw Data' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
ORDER BY POSN.EFFDT DESC;

DECLARE @raw_count INT = @@ROWCOUNT;
PRINT 'Total raw position records: ' + CAST(@raw_count AS VARCHAR(10))
PRINT ''

-- Step 2: Apply EFF_STATUS = 'A' filter
PRINT '=== STEP 2: AFTER EFF_STATUS = ''A'' FILTER ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.DESCR,
    POSN.DML_IND,
    'After EFF_STATUS Filter' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
ORDER BY POSN.EFFDT DESC;

DECLARE @eff_status_count INT = @@ROWCOUNT;
PRINT 'Records after EFF_STATUS filter: ' + CAST(@eff_status_count AS VARCHAR(10))
PRINT ''

-- Step 3: Apply BUSINESS_UNIT filter
PRINT '=== STEP 3: AFTER BUSINESS_UNIT IN (''SDCMP'',''SDMED'') FILTER ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.DESCR,
    POSN.DML_IND,
    'After BUSINESS_UNIT Filter' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
ORDER BY POSN.EFFDT DESC;

DECLARE @bu_count INT = @@ROWCOUNT;
PRINT 'Records after BUSINESS_UNIT filter: ' + CAST(@bu_count AS VARCHAR(10))
PRINT ''

-- Step 4: Apply DML_IND filter
PRINT '=== STEP 4: AFTER DML_IND <> ''D'' FILTER ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.DESCR,
    POSN.DML_IND,
    'After DML_IND Filter' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
ORDER BY POSN.EFFDT DESC;

DECLARE @dml_count INT = @@ROWCOUNT;
PRINT 'Records after DML_IND filter: ' + CAST(@dml_count AS VARCHAR(10))
PRINT ''

-- Step 5: Apply EFFDT <= GETDATE() filter
PRINT '=== STEP 5: AFTER EFFDT <= GETDATE() FILTER ==='
PRINT 'Current Date: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.DESCR,
    POSN.DML_IND,
    'After EFFDT Filter' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
    AND POSN.EFFDT <= GETDATE()
ORDER BY POSN.EFFDT DESC;

DECLARE @effdt_count INT = @@ROWCOUNT;
PRINT 'Records after EFFDT filter: ' + CAST(@effdt_count AS VARCHAR(10))
PRINT ''

-- Step 6: Apply MAX EFFDT filter (Final filtered data)
PRINT '=== STEP 6: AFTER MAX EFFDT FILTER (Final Position Data) ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    POSN.JOBCODE,
    POSN.POSN_STATUS,
    POSN.STATUS_DT,
    POSN.DESCR,
    POSN.FTE,
    POSN.REPORTS_TO,
    POSN.DML_IND,
    'Final Position Data' AS Filter_Step
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
    AND POSN.EFFDT = (
        SELECT MAX(POSN1.EFFDT)
    FROM STABLE.PS_POSITION_DATA POSN1
    WHERE POSN1.POSITION_NBR = POSN.POSITION_NBR
        AND POSN1.EFFDT <= GETDATE()
        AND POSN1.DML_IND <> 'D'
    );

DECLARE @final_count INT = @@ROWCOUNT;
PRINT 'Records after MAX EFFDT filter: ' + CAST(@final_count AS VARCHAR(10))
PRINT ''

-- Step 7: Show job code lookup logic
PRINT '=== STEP 7: JOB CODE LOOKUP ANALYSIS ==='
PRINT 'Checking JOBCODE_TBL lookup for position ' + @POSITION_NBR

-- First, get the position's jobcode and effdt
DECLARE @pos_jobcode VARCHAR(10), @pos_effdt DATETIME;
SELECT
    @pos_jobcode = POSN.JOBCODE,
    @pos_effdt = POSN.EFFDT
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
    AND POSN.EFFDT = (
        SELECT MAX(POSN1.EFFDT)
    FROM STABLE.PS_POSITION_DATA POSN1
    WHERE POSN1.POSITION_NBR = POSN.POSITION_NBR
        AND POSN1.EFFDT <= GETDATE()
        AND POSN1.DML_IND <> 'D'
    );

PRINT 'Position JOBCODE: ' + ISNULL(@pos_jobcode, 'NULL')
PRINT 'Position EFFDT: ' + ISNULL(CONVERT(VARCHAR(30), @pos_effdt, 120), 'NULL')
PRINT ''

-- Show all jobcode records for this jobcode
SELECT
    H.JOBCODE,
    H.SETID,
    H.EFFDT,
    H.EFF_STATUS,
    H.DESCR,
    H.DML_IND,
    CASE WHEN H.EFFDT <= @pos_effdt THEN 'Valid for Position EFFDT' ELSE 'Future Dated' END AS EFFDT_Status,
    'All Jobcode Records' AS Analysis_Step
FROM STABLE.PS_JOBCODE_TBL H
WHERE H.JOBCODE = @pos_jobcode
    AND H.SETID = 'UCSHR'
ORDER BY H.EFFDT DESC;

PRINT ''

-- Show the specific jobcode record that would be selected
SELECT
    H.JOBCODE,
    H.SETID,
    H.EFFDT,
    H.EFF_STATUS,
    H.DESCR,
    H.DML_IND,
    'Selected Jobcode Record' AS Analysis_Step
FROM STABLE.PS_JOBCODE_TBL H
WHERE H.JOBCODE = @pos_jobcode
    AND H.SETID = 'UCSHR'
    AND H.EFF_STATUS = 'A'
    AND H.EFFDT = (
        SELECT MAX(H_ED.EFFDT)
    FROM STABLE.PS_JOBCODE_TBL H_ED
    WHERE H.SETID = H_ED.SETID
        AND H.JOBCODE = H_ED.JOBCODE
        AND H_ED.EFF_STATUS = 'A'
        AND H_ED.EFFDT <= @pos_effdt
        AND H_ED.DML_IND <> 'D'
    )
    AND H.DML_IND <> 'D';

PRINT ''

-- Step 8: Show department hierarchy lookup
PRINT '=== STEP 8: DEPARTMENT HIERARCHY LOOKUP ANALYSIS ==='

-- Get the position's deptid
DECLARE @pos_deptid VARCHAR(10);
SELECT
    @pos_deptid = POSN.DEPTID
FROM STABLE.PS_POSITION_DATA POSN
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
    AND POSN.EFFDT = (
        SELECT MAX(POSN1.EFFDT)
    FROM STABLE.PS_POSITION_DATA POSN1
    WHERE POSN1.POSITION_NBR = POSN.POSITION_NBR
        AND POSN1.EFFDT <= GETDATE()
        AND POSN1.DML_IND <> 'D'
    );

PRINT 'Position DEPTID: ' + ISNULL(@pos_deptid, 'NULL')

SELECT
    DEPT_VC.DEPTID,
    DEPT_VC.DESCR AS DEPTID_DESCR,
    DEPT_VC.VC_CODE,
    DEPT_VC.VC_NAME,
    'Department Hierarchy Record' AS Analysis_Step
FROM RPT.DEPARTMENT_HIERARCHY DEPT_VC
WHERE DEPT_VC.DEPTID = @pos_deptid;

PRINT ''

-- Step 9: Final query results with all joins
PRINT '=== STEP 9: FINAL QUERY RESULTS (With All Joins) ==='
SELECT
    POSN.POSITION_NBR,
    POSN.EFFDT,
    POSN.EFF_STATUS,
    POSN.DESCR,
    POSN.BUSINESS_UNIT,
    POSN.DEPTID,
    DEPT_VC.DESCR AS DEPTID_DESCR,
    POSN.JOBCODE,
    H.DESCR AS JOBCODE_DESCR,
    POSN.POSN_STATUS,
    POSN.STATUS_DT,
    POSN.FTE,
    -- Special case for REPORTS_TO
    CASE WHEN POSN.POSITION_NBR = '40697795' THEN '40786234' 
         ELSE POSN.REPORTS_TO END AS REPORTS_TO,
    POSN.DML_IND,
    DEPT_VC.VC_CODE,
    DEPT_VC.VC_NAME,
    'Final Query Result' AS Analysis_Step
FROM STABLE.PS_POSITION_DATA POSN
    LEFT OUTER JOIN STABLE.PS_JOBCODE_TBL H
    ON H.JOBCODE = POSN.JOBCODE
        AND H.SETID = 'UCSHR'
        AND H.EFF_STATUS = 'A'
        AND H.EFFDT = (
            SELECT MAX(H_ED.EFFDT)
        FROM STABLE.PS_JOBCODE_TBL H_ED
        WHERE H.SETID = H_ED.SETID
            AND H.JOBCODE = H_ED.JOBCODE
            AND H_ED.EFF_STATUS = 'A'
            AND H_ED.EFFDT <= POSN.EFFDT
            AND H_ED.DML_IND <> 'D'
        )
        AND H.DML_IND <> 'D'
    LEFT OUTER JOIN RPT.DEPARTMENT_HIERARCHY DEPT_VC
    ON POSN.DEPTID = DEPT_VC.DEPTID
WHERE POSN.POSITION_NBR = @POSITION_NBR
    AND POSN.EFF_STATUS = 'A'
    AND POSN.BUSINESS_UNIT IN ('SDCMP','SDMED')
    AND POSN.DML_IND <> 'D'
    AND POSN.EFFDT = (
        SELECT MAX(POSN1.EFFDT)
    FROM STABLE.PS_POSITION_DATA POSN1
    WHERE POSN1.POSITION_NBR = POSN.POSITION_NBR
        AND POSN1.EFFDT <= GETDATE()
        AND POSN1.DML_IND <> 'D'   
    );

DECLARE @final_result_count INT = @@ROWCOUNT;
PRINT 'Final query result count: ' + CAST(@final_result_count AS VARCHAR(10))
PRINT ''

-- Step 10: Summary
PRINT '=== SUMMARY ==='
PRINT 'Position Number: ' + @POSITION_NBR
PRINT 'Raw Position Records: ' + CAST(@raw_count AS VARCHAR(10))
PRINT 'After EFF_STATUS Filter: ' + CAST(@eff_status_count AS VARCHAR(10))
PRINT 'After BUSINESS_UNIT Filter: ' + CAST(@bu_count AS VARCHAR(10))
PRINT 'After DML_IND Filter: ' + CAST(@dml_count AS VARCHAR(10))
PRINT 'After EFFDT Filter: ' + CAST(@effdt_count AS VARCHAR(10))
PRINT 'After MAX EFFDT Filter: ' + CAST(@final_count AS VARCHAR(10))
PRINT 'Final Query Results: ' + CAST(@final_result_count AS VARCHAR(10))
PRINT ''

-- Special case handling note
PRINT '=== SPECIAL CASE HANDLING ==='
PRINT 'Note: Position 40697795 has special REPORTS_TO override to 40786234'
IF @POSITION_NBR = '40697795'
    PRINT '✅ This position has the special REPORTS_TO override applied'
ELSE
    PRINT '❌ This position uses standard REPORTS_TO logic'
PRINT ''

PRINT '=== QA ANALYSIS COMPLETED ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
GO
