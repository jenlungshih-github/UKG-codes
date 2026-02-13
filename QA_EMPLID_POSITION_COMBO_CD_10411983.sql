USE [HealthTime]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  QA Query for: Employee Position FDM_COMBO_CD Analysis
--  Target EMPLID: 10411983
--  Author:         Jim Shih
--  Date:           11/02/2025
--  Description:    This QA query analyzes the relationship between employee, position, 
--                  and FDM_COMBO_CD for a specific employee to validate data consistency.
--                  
--  Steps:
--  1. Check employee data in UKG_EMPLOYEE_DATA
--  2. Check position data in CURRENT_POSITION_PRI_FIN_UNIT
--  3. Show the JOIN relationship and FDM_COMBO_CD mapping
--  4. Validate data consistency
--
--  Usage:          Run this entire script to get comprehensive QA results
***************************************************************************************************************************************************************************************************************************************************************/

DECLARE @EMPLID VARCHAR(11) = '10411983';

PRINT '=== QA ANALYSIS FOR EMPLID_POSITION_COMBO_CD: ' + @EMPLID + ' ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
PRINT ''

-- Step 1: Check employee data in UKG_EMPLOYEE_DATA
PRINT '=== STEP 1: UKG_EMPLOYEE_DATA RECORDS ==='
SELECT
    UKG.emplid,
    UKG.position_nbr,
    --    UKG.[Employee Name],
    UKG.[DEPTID],
    --    UKG.[Department Name],
    UKG.[Employment Status],
    UKG.[Hire Date],
    UKG.[snapshot_date],
    'UKG_EMPLOYEE_DATA' AS Source_Table
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] UKG
WHERE UKG.emplid = @EMPLID;

DECLARE @ukg_count INT = @@ROWCOUNT;
PRINT 'UKG_EMPLOYEE_DATA records found: ' + CAST(@ukg_count AS VARCHAR(10))

-- Get position number for further analysis
DECLARE @position_nbr VARCHAR(20);
SELECT @position_nbr = UKG.position_nbr
FROM [dbo].[UKG_EMPLOYEE_DATA] UKG
WHERE UKG.emplid = @EMPLID;

PRINT 'Employee Position Number: ' + ISNULL(@position_nbr, 'NULL')
PRINT ''

-- Step 2: Check all position financial unit records
PRINT '=== STEP 2: CURRENT_POSITION_PRI_FIN_UNIT RECORDS ==='
SELECT
    FIN.position_nbr,
    FIN.FDM_COMBO_CD,
    FIN.POSN_SEQ,
    FIN.POSN_DESCR,
    FIN.DEPTID,
    FIN.ACCOUNT,
    FIN.FUND_CODE,
    FIN.OPERATING_UNIT,
    FIN.ERNCD,
    FIN.DIST_PCT,
    'CURRENT_POSITION_PRI_FIN_UNIT' AS Source_Table
FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
WHERE FIN.position_nbr = @position_nbr
ORDER BY FIN.POSN_SEQ;

DECLARE @fin_count INT = @@ROWCOUNT;
PRINT 'CURRENT_POSITION_PRI_FIN_UNIT records found: ' + CAST(@fin_count AS VARCHAR(10))
PRINT ''

-- Step 3: Show the primary financial unit (POSN_SEQ = 1)
PRINT '=== STEP 3: PRIMARY FINANCIAL UNIT (POSN_SEQ = 1) ==='
SELECT
    FIN.position_nbr,
    FIN.FDM_COMBO_CD,
    FIN.POSN_SEQ,
    FIN.POSN_DESCR,
    FIN.DEPTID,
    FIN.ACCOUNT,
    FIN.FUND_CODE,
    FIN.OPERATING_UNIT,
    FIN.ERNCD,
    FIN.DIST_PCT,
    'Primary Financial Unit' AS Analysis_Step
FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT] FIN
WHERE FIN.position_nbr = @position_nbr
    AND FIN.POSN_SEQ = 1;

DECLARE @primary_count INT = @@ROWCOUNT;
PRINT 'Primary financial unit records: ' + CAST(@primary_count AS VARCHAR(10))
PRINT ''

-- Step 4: Show the JOIN result (matching the original query logic)
PRINT '=== STEP 4: JOIN RESULT (UKG + PRIMARY FIN UNIT) ==='
SELECT
    UKG.emplid,
    UKG.position_nbr,
    --    UKG.[Employee Name],
    FIN.FDM_COMBO_CD,
    FIN.POSN_SEQ,
    FIN.POSN_DESCR,
    FIN.DEPTID AS FIN_DEPTID,
    UKG.[DEPTID] AS UKG_DEPTID,
    FIN.ACCOUNT,
    FIN.FUND_CODE,
    FIN.OPERATING_UNIT,
    'JOIN Result' AS Analysis_Step
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] UKG
    LEFT JOIN (
        SELECT
        position_nbr,
        FDM_COMBO_CD,
        POSN_SEQ,
        POSN_DESCR,
        DEPTID,
        ACCOUNT,
        FUND_CODE,
        OPERATING_UNIT,
        ROW_NUMBER() OVER (PARTITION BY position_nbr ORDER BY POSN_SEQ ASC) as rn
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
    ) FIN
    ON UKG.position_nbr = FIN.position_nbr AND FIN.rn = 1
WHERE UKG.emplid = @EMPLID;

DECLARE @join_count INT = @@ROWCOUNT;
PRINT 'JOIN result records: ' + CAST(@join_count AS VARCHAR(10))
PRINT ''

-- Step 5: Data validation checks
PRINT '=== STEP 5: DATA VALIDATION CHECKS ==='

-- Check if employee exists in UKG data
IF @ukg_count = 0
    PRINT '❌ ISSUE: Employee not found in UKG_EMPLOYEE_DATA'
ELSE
    PRINT '✅ PASS: Employee found in UKG_EMPLOYEE_DATA'

-- Check if position has financial data
IF @fin_count = 0
    PRINT '❌ ISSUE: No financial unit records found for position ' + ISNULL(@position_nbr, 'NULL')
ELSE
    PRINT '✅ PASS: Position has ' + CAST(@fin_count AS VARCHAR(10)) + ' financial unit record(s)'

-- Check if primary financial unit exists
IF @primary_count = 0
    PRINT '❌ ISSUE: No primary financial unit (POSN_SEQ=1) found for position'
ELSE
    PRINT '✅ PASS: Primary financial unit found'

-- Check JOIN success
IF @join_count = 0
    PRINT '❌ ISSUE: JOIN failed - no combined record produced'
ELSE
    PRINT '✅ PASS: JOIN successful - combined record available'

PRINT ''

-- Step 6: Get the final FDM_COMBO_CD for this employee
PRINT '=== STEP 6: FINAL FDM_COMBO_CD RESULT ==='
DECLARE @fdm_combo_cd VARCHAR(50);
SELECT
    @fdm_combo_cd = FIN.FDM_COMBO_CD
FROM [dbo].[UKG_EMPLOYEE_DATA] UKG
    LEFT JOIN (
        SELECT
        position_nbr,
        FDM_COMBO_CD,
        POSN_SEQ,
        ROW_NUMBER() OVER (PARTITION BY position_nbr ORDER BY POSN_SEQ ASC) as rn
    FROM health_ods.[health_ods].[RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
    ) FIN
    ON UKG.position_nbr = FIN.position_nbr AND FIN.rn = 1
WHERE UKG.emplid = @EMPLID;

PRINT 'Employee ID: ' + @EMPLID
PRINT 'Position Number: ' + ISNULL(@position_nbr, 'NULL')
PRINT 'FDM_COMBO_CD: ' + ISNULL(@fdm_combo_cd, 'NULL')
PRINT ''

-- Step 7: Summary
PRINT '=== SUMMARY ==='
PRINT 'Employee: ' + @EMPLID
PRINT 'UKG Records: ' + CAST(@ukg_count AS VARCHAR(10))
PRINT 'Position Financial Records: ' + CAST(@fin_count AS VARCHAR(10))
PRINT 'Primary Financial Record: ' + CAST(@primary_count AS VARCHAR(10))
PRINT 'Final JOIN Result: ' + CAST(@join_count AS VARCHAR(10))
PRINT 'Final FDM_COMBO_CD: ' + ISNULL(@fdm_combo_cd, 'NULL')
PRINT ''

IF @ukg_count > 0 AND @fin_count > 0 AND @primary_count > 0 AND @join_count > 0 AND @fdm_combo_cd IS NOT NULL
    PRINT '✅ OVERALL STATUS: All data relationships are valid'
ELSE
    PRINT '❌ OVERALL STATUS: Data quality issues detected - investigation needed'

PRINT ''
PRINT '=== QA ANALYSIS COMPLETED ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
GO
