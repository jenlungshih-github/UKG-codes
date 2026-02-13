USE [Health_ODS]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  QA Query for: [RPT].[CURRENT_POSITION_PRI_FIN_UNIT] View
--  Target POSITION_NBR: 40882509
--  Author:         Jim Shih
--  Date:           10/29/2025
--  Description:    This QA query breaks down the view logic step by step to validate
--                  the filtering and ranking logic for a specific position number.
--                  
--  Steps:
--  1. Check base position data
--  2. Show all budget records before filtering
--  3. Apply each filter step by step
--  4. Show final ranking logic
--  5. Compare with actual view results
--
--  Usage:          Run this entire script to get comprehensive QA results
***************************************************************************************************************************************************************************************************************************************************************/

DECLARE @POSITION_NBR VARCHAR(20) = '40882509';

PRINT '=== QA ANALYSIS FOR POSITION: ' + @POSITION_NBR + ' ===';
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120);
PRINT '';

-- Step 1: Check if position exists in base table
PRINT '=== STEP 1: BASE POSITION DATA ==='
SELECT
    POSITION_NBR,
    DESCR AS POSN_DESCR,
    DEPTID,
    DEPTID_DESCR,
    JOBCODE,
    JOBCODE_DESCR,
    FTE,
    REPORTS_TO,
    POSN_STATUS
FROM [RPT].[CURRENT_POSITION]
WHERE POSITION_NBR = @POSITION_NBR;

IF @@ROWCOUNT = 0
    PRINT '❌ No position found in CURRENT_POSITION table'
ELSE
    PRINT '✅ Position found in CURRENT_POSITION table'

PRINT '';

-- Step 2: Show all budget records before any filtering
PRINT '=== STEP 2: ALL BUDGET RECORDS (Before Filtering) ==='
SELECT
    F.POSITION_NBR,
    F.ERNCD,
    F.FISCAL_YEAR,
    F.EFFDT,
    F.EFFSEQ,
    F.BUDGET_SEQ,
    F.DIST_PCT,
    F.ACCT_CD,
    F.DML_IND,
    F.FUNDING_END_DT,
    F.SETID,
    'Raw Data' AS Filter_Step
FROM STABLE.PS_DEPT_BUDGET_ERN F
WHERE F.POSITION_NBR = @POSITION_NBR
ORDER BY F.FISCAL_YEAR DESC, F.EFFDT DESC, F.EFFSEQ DESC, F.BUDGET_SEQ DESC;

DECLARE @raw_count INT = @@ROWCOUNT;
PRINT 'Total raw budget records: ' + CAST(@raw_count AS VARCHAR(10))
PRINT '';

-- Step 3: Apply DML_IND filter
PRINT '=== STEP 3: AFTER DML_IND <> ''D'' FILTER ==='
SELECT
    F.POSITION_NBR,
    F.ERNCD,
    F.FISCAL_YEAR,
    F.EFFDT,
    F.EFFSEQ,
    F.BUDGET_SEQ,
    F.DIST_PCT,
    F.ACCT_CD,
    F.DML_IND,
    'After DML Filter' AS Filter_Step
FROM STABLE.PS_DEPT_BUDGET_ERN F
WHERE F.POSITION_NBR = @POSITION_NBR
    AND F.DML_IND <> 'D'
ORDER BY F.FISCAL_YEAR DESC, F.EFFDT DESC, F.EFFSEQ DESC, F.BUDGET_SEQ DESC;

DECLARE @dml_count INT = @@ROWCOUNT;
PRINT 'Records after DML_IND filter: ' + CAST(@dml_count AS VARCHAR(10))
PRINT '';

-- Step 4: Apply funding end date filter
PRINT '=== STEP 4: AFTER FUNDING_END_DT FILTER ==='
SELECT
    F.POSITION_NBR,
    F.ERNCD,
    F.FISCAL_YEAR,
    F.EFFDT,
    F.EFFSEQ,
    F.BUDGET_SEQ,
    F.DIST_PCT,
    F.ACCT_CD,
    F.FUNDING_END_DT,
    'After Funding End Date Filter' AS Filter_Step
FROM STABLE.PS_DEPT_BUDGET_ERN F
WHERE F.POSITION_NBR = @POSITION_NBR
    AND F.DML_IND <> 'D'
    AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
ORDER BY F.FISCAL_YEAR DESC, F.EFFDT DESC, F.EFFSEQ DESC, F.BUDGET_SEQ DESC;

DECLARE @funding_count INT = @@ROWCOUNT;
PRINT 'Records after FUNDING_END_DT filter: ' + CAST(@funding_count AS VARCHAR(10))
PRINT '';

-- Step 5: Apply SETID and current fiscal year filter
PRINT '=== STEP 5: AFTER SETID AND FISCAL_YEAR FILTER ==='
PRINT 'Current Fiscal Year: ' + CAST(YEAR(DATEADD(MONTH, 6, GETDATE())) AS VARCHAR(10))
SELECT
    F.POSITION_NBR,
    F.ERNCD,
    F.FISCAL_YEAR,
    F.EFFDT,
    F.EFFSEQ,
    F.BUDGET_SEQ,
    F.DIST_PCT,
    F.ACCT_CD,
    F.SETID,
    'After SETID/FY Filter' AS Filter_Step
FROM STABLE.PS_DEPT_BUDGET_ERN F
WHERE F.POSITION_NBR = @POSITION_NBR
    AND F.DML_IND <> 'D'
    AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
    AND F.SETID = 'SDCMP'
    AND F.FISCAL_YEAR = YEAR(DATEADD(MONTH, 6, GETDATE()))
ORDER BY F.FISCAL_YEAR DESC, F.EFFDT DESC, F.EFFSEQ DESC, F.BUDGET_SEQ DESC;

DECLARE @setid_count INT = @@ROWCOUNT;
PRINT 'Records after SETID/FISCAL_YEAR filter: ' + CAST(@setid_count AS VARCHAR(10))
PRINT '';

-- Step 6: Apply MAX EFFDT filter
PRINT '=== STEP 6: AFTER MAX EFFDT FILTER ==='
WITH
    MaxEffdtRecords
    AS
    (
        SELECT
            F.POSITION_NBR,
            F.ERNCD,
            F.FISCAL_YEAR,
            F.EFFDT,
            F.EFFSEQ,
            F.BUDGET_SEQ,
            F.DIST_PCT,
            F.ACCT_CD,
            F.SETID,
            F.DEPTID,
            F.POSITION_POOL_ID,
            F.SETID_JOBCODE,
            F.JOBCODE,
            F.EMPLID,
            F.EMPL_RCD
        FROM STABLE.PS_DEPT_BUDGET_ERN F
        WHERE F.POSITION_NBR = @POSITION_NBR
            AND F.DML_IND <> 'D'
            AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
            AND F.SETID = 'SDCMP'
            AND F.FISCAL_YEAR = YEAR(DATEADD(MONTH, 6, GETDATE()))
            AND F.EFFDT = (
            SELECT MAX(F_ED.EFFDT)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ED
            WHERE F.SETID = F_ED.SETID
                AND F.DEPTID = F_ED.DEPTID
                AND F.FISCAL_YEAR = F_ED.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ED.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ED.SETID_JOBCODE
                AND F.JOBCODE = F_ED.JOBCODE
                AND F.POSITION_NBR = F_ED.POSITION_NBR
                AND F.EMPLID = F_ED.EMPLID
                AND F.EMPL_RCD = F_ED.EMPL_RCD
                AND F_ED.EFFDT <= CURRENT_TIMESTAMP
                AND F_ED.DML_IND <> 'D'
        )
    )
SELECT
    POSITION_NBR,
    ERNCD,
    FISCAL_YEAR,
    EFFDT,
    EFFSEQ,
    BUDGET_SEQ,
    DIST_PCT,
    ACCT_CD,
    'After MAX EFFDT Filter' AS Filter_Step
FROM MaxEffdtRecords
ORDER BY FISCAL_YEAR DESC, EFFDT DESC, EFFSEQ DESC, BUDGET_SEQ DESC;

DECLARE @effdt_count INT = @@ROWCOUNT;
PRINT 'Records after MAX EFFDT filter: ' + CAST(@effdt_count AS VARCHAR(10))
PRINT '';

-- Step 7: Apply MAX EFFSEQ filter
PRINT '=== STEP 7: AFTER MAX EFFSEQ FILTER ==='
WITH
    MaxEffseqRecords
    AS
    (
        SELECT
            F.POSITION_NBR,
            F.ERNCD,
            F.FISCAL_YEAR,
            F.EFFDT,
            F.EFFSEQ,
            F.BUDGET_SEQ,
            F.DIST_PCT,
            F.ACCT_CD,
            F.SETID,
            F.DEPTID,
            F.POSITION_POOL_ID,
            F.SETID_JOBCODE,
            F.JOBCODE,
            F.EMPLID,
            F.EMPL_RCD
        FROM STABLE.PS_DEPT_BUDGET_ERN F
        WHERE F.POSITION_NBR = @POSITION_NBR
            AND F.DML_IND <> 'D'
            AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
            AND F.SETID = 'SDCMP'
            AND F.FISCAL_YEAR = YEAR(DATEADD(MONTH, 6, GETDATE()))
            AND F.EFFDT = (
            SELECT MAX(F_ED.EFFDT)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ED
            WHERE F.SETID = F_ED.SETID
                AND F.DEPTID = F_ED.DEPTID
                AND F.FISCAL_YEAR = F_ED.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ED.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ED.SETID_JOBCODE
                AND F.JOBCODE = F_ED.JOBCODE
                AND F.POSITION_NBR = F_ED.POSITION_NBR
                AND F.EMPLID = F_ED.EMPLID
                AND F.EMPL_RCD = F_ED.EMPL_RCD
                AND F_ED.EFFDT <= CURRENT_TIMESTAMP
                AND F_ED.DML_IND <> 'D'
        )
            AND F.EFFSEQ = (
            SELECT MAX(F_ES.EFFSEQ)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ES
            WHERE F.SETID = F_ES.SETID
                AND F.DEPTID = F_ES.DEPTID
                AND F.FISCAL_YEAR = F_ES.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ES.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ES.SETID_JOBCODE
                AND F.JOBCODE = F_ES.JOBCODE
                AND F.POSITION_NBR = F_ES.POSITION_NBR
                AND F.EMPLID = F_ES.EMPLID
                AND F.EMPL_RCD = F_ES.EMPL_RCD
                AND F.EFFDT = F_ES.EFFDT
                AND F_ES.DML_IND <> 'D'
        )
    )
SELECT
    POSITION_NBR,
    ERNCD,
    FISCAL_YEAR,
    EFFDT,
    EFFSEQ,
    BUDGET_SEQ,
    DIST_PCT,
    ACCT_CD,
    'After MAX EFFSEQ Filter' AS Filter_Step
FROM MaxEffseqRecords
ORDER BY FISCAL_YEAR DESC, EFFDT DESC, EFFSEQ DESC, BUDGET_SEQ DESC;

DECLARE @effseq_count INT = @@ROWCOUNT;
PRINT 'Records after MAX EFFSEQ filter: ' + CAST(@effseq_count AS VARCHAR(10))
PRINT '';

-- Step 8: Apply MAX BUDGET_SEQ filter (Final filtered data)
PRINT '=== STEP 8: AFTER MAX BUDGET_SEQ FILTER (Final Filtered Data) ==='
WITH
    FinalFilteredRecords
    AS
    (
        SELECT
            F.POSITION_NBR,
            F.ERNCD,
            F.FISCAL_YEAR,
            F.EFFDT,
            F.EFFSEQ,
            F.BUDGET_SEQ,
            F.DIST_PCT,
            F.ACCT_CD
        FROM STABLE.PS_DEPT_BUDGET_ERN F
        WHERE F.POSITION_NBR = @POSITION_NBR
            AND F.DML_IND <> 'D'
            AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
            AND F.SETID = 'SDCMP'
            AND F.FISCAL_YEAR = YEAR(DATEADD(MONTH, 6, GETDATE()))
            AND F.EFFDT = (
            SELECT MAX(F_ED.EFFDT)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ED
            WHERE F.SETID = F_ED.SETID
                AND F.DEPTID = F_ED.DEPTID
                AND F.FISCAL_YEAR = F_ED.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ED.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ED.SETID_JOBCODE
                AND F.JOBCODE = F_ED.JOBCODE
                AND F.POSITION_NBR = F_ED.POSITION_NBR
                AND F.EMPLID = F_ED.EMPLID
                AND F.EMPL_RCD = F_ED.EMPL_RCD
                AND F_ED.EFFDT <= CURRENT_TIMESTAMP
                AND F_ED.DML_IND <> 'D'
        )
            AND F.EFFSEQ = (
            SELECT MAX(F_ES.EFFSEQ)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ES
            WHERE F.SETID = F_ES.SETID
                AND F.DEPTID = F_ES.DEPTID
                AND F.FISCAL_YEAR = F_ES.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ES.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ES.SETID_JOBCODE
                AND F.JOBCODE = F_ES.JOBCODE
                AND F.POSITION_NBR = F_ES.POSITION_NBR
                AND F.EMPLID = F_ES.EMPLID
                AND F.EMPL_RCD = F_ES.EMPL_RCD
                AND F.EFFDT = F_ES.EFFDT
                AND F_ES.DML_IND <> 'D'
        )
            AND F.BUDGET_SEQ = (
            SELECT MAX(FF.BUDGET_SEQ)
            FROM STABLE.PS_DEPT_BUDGET_ERN FF
            WHERE FF.SETID = F.SETID
                AND FF.DEPTID = F.DEPTID
                AND FF.FISCAL_YEAR = F.FISCAL_YEAR
                AND FF.POSITION_NBR = F.POSITION_NBR
                AND FF.EMPLID = F.EMPLID
                AND FF.EMPL_RCD = F.EMPL_RCD
                AND FF.EFFDT = F.EFFDT
                AND FF.EFFSEQ = F.EFFSEQ
                AND FF.ERNCD = F.ERNCD
                AND FF.DML_IND <> 'D'
        )
    )
SELECT
    POSITION_NBR,
    ERNCD,
    FISCAL_YEAR,
    EFFDT,
    EFFSEQ,
    BUDGET_SEQ,
    DIST_PCT,
    ACCT_CD,
    -- Show ranking logic
    CASE WHEN ERNCD = 'REG' THEN 'ZZZ'  
         WHEN ERNCD = '' THEN 'ZZY' 
         ELSE ERNCD END AS ERNCD_Sort_Value,
    'Final Filtered Data' AS Filter_Step
FROM FinalFilteredRecords
ORDER BY 
    (CASE WHEN ERNCD = 'REG' THEN 'ZZZ'  WHEN ERNCD = '' THEN 'ZZY' ELSE ERNCD END) DESC, 
    DIST_PCT DESC, 
    ACCT_CD;

DECLARE @final_count INT = @@ROWCOUNT;
PRINT 'Records after MAX BUDGET_SEQ filter: ' + CAST(@final_count AS VARCHAR(10))
PRINT '';

-- Step 9: Show POSN_SEQ ranking logic
PRINT '=== STEP 9: POSN_SEQ RANKING LOGIC ==='
WITH
    RankedRecords
    AS
    (
        SELECT
            F.POSITION_NBR,
            F.ERNCD,
            F.FISCAL_YEAR,
            F.EFFDT,
            F.EFFSEQ,
            F.BUDGET_SEQ,
            F.DIST_PCT,
            F.ACCT_CD,
            CASE WHEN F.ERNCD = 'REG' THEN 'ZZZ'  
             WHEN F.ERNCD = '' THEN 'ZZY' 
             ELSE F.ERNCD END AS ERNCD_Sort_Value,
            ROW_NUMBER() OVER (
            PARTITION BY F.POSITION_NBR 
            ORDER BY (CASE WHEN F.ERNCD = 'REG' THEN 'ZZZ'  WHEN F.ERNCD = '' THEN 'ZZY' ELSE F.ERNCD END) DESC, 
                     F.DIST_PCT DESC, 
                     F.ACCT_CD
        ) AS POSN_SEQ
        FROM STABLE.PS_DEPT_BUDGET_ERN F
        WHERE F.POSITION_NBR = @POSITION_NBR
            AND F.DML_IND <> 'D'
            AND (F.FUNDING_END_DT >= CURRENT_TIMESTAMP OR F.FUNDING_END_DT IS NULL)
            AND F.SETID = 'SDCMP'
            AND F.FISCAL_YEAR = YEAR(DATEADD(MONTH, 6, GETDATE()))
            AND F.EFFDT = (
            SELECT MAX(F_ED.EFFDT)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ED
            WHERE F.SETID = F_ED.SETID
                AND F.DEPTID = F_ED.DEPTID
                AND F.FISCAL_YEAR = F_ED.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ED.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ED.SETID_JOBCODE
                AND F.JOBCODE = F_ED.JOBCODE
                AND F.POSITION_NBR = F_ED.POSITION_NBR
                AND F.EMPLID = F_ED.EMPLID
                AND F.EMPL_RCD = F_ED.EMPL_RCD
                AND F_ED.EFFDT <= CURRENT_TIMESTAMP
                AND F_ED.DML_IND <> 'D'
        )
            AND F.EFFSEQ = (
            SELECT MAX(F_ES.EFFSEQ)
            FROM STABLE.PS_DEPT_BUDGET_ERN F_ES
            WHERE F.SETID = F_ES.SETID
                AND F.DEPTID = F_ES.DEPTID
                AND F.FISCAL_YEAR = F_ES.FISCAL_YEAR
                AND F.POSITION_POOL_ID = F_ES.POSITION_POOL_ID
                AND F.SETID_JOBCODE = F_ES.SETID_JOBCODE
                AND F.JOBCODE = F_ES.JOBCODE
                AND F.POSITION_NBR = F_ES.POSITION_NBR
                AND F.EMPLID = F_ES.EMPLID
                AND F.EMPL_RCD = F_ES.EMPL_RCD
                AND F.EFFDT = F_ES.EFFDT
                AND F_ES.DML_IND <> 'D'
        )
            AND F.BUDGET_SEQ = (
            SELECT MAX(FF.BUDGET_SEQ)
            FROM STABLE.PS_DEPT_BUDGET_ERN FF
            WHERE FF.SETID = F.SETID
                AND FF.DEPTID = F.DEPTID
                AND FF.FISCAL_YEAR = F.FISCAL_YEAR
                AND FF.POSITION_NBR = F.POSITION_NBR
                AND FF.EMPLID = F.EMPLID
                AND FF.EMPL_RCD = F.EMPL_RCD
                AND FF.EFFDT = F.EFFDT
                AND FF.EFFSEQ = F.EFFSEQ
                AND FF.ERNCD = F.ERNCD
                AND FF.DML_IND <> 'D'
        )
    )
SELECT
    POSITION_NBR,
    ERNCD,
    ERNCD_Sort_Value,
    DIST_PCT,
    ACCT_CD,
    POSN_SEQ,
    'Ranked Records' AS Filter_Step
FROM RankedRecords
ORDER BY POSN_SEQ;

PRINT 'POSN_SEQ Ranking Logic:'
PRINT '1. ERNCD = ''REG'' gets sort value ''ZZZ'' (highest priority)'
PRINT '2. ERNCD = '''' (blank) gets sort value ''ZZY'' (second priority)'
PRINT '3. Other ERNCD values keep their original value (lower priority)'
PRINT '4. Then ordered by DIST_PCT DESC, then ACCT_CD ASC'
PRINT '';

-- Step 10: Compare with actual view results
PRINT '=== STEP 10: ACTUAL VIEW RESULTS ==='
SELECT
    POSITION_NBR,
    POSN_DESCR,
    DEPTID,
    JOBCODE,
    FTE,
    ACCOUNT,
    DEPTID_CF,
    FUND_CODE,
    OPERATING_UNIT,
    FDM_COMBO_CD,
    ERNCD,
    FISCAL_YEAR,
    DIST_PCT,
    PROJECT_ID,
    PRODUCT,
    PROGRAM_CODE,
    CLASS_FLD,
    POSN_SEQ
FROM [RPT].[CURRENT_POSITION_PRI_FIN_UNIT]
WHERE POSITION_NBR = @POSITION_NBR
ORDER BY POSN_SEQ;

DECLARE @view_count INT = @@ROWCOUNT;
PRINT 'Records in actual view: ' + CAST(@view_count AS VARCHAR(10))
PRINT '';

-- Step 11: Summary
PRINT '=== SUMMARY ==='
PRINT 'Position Number: ' + @POSITION_NBR
PRINT 'Raw Budget Records: ' + CAST(@raw_count AS VARCHAR(10))
PRINT 'After DML Filter: ' + CAST(@dml_count AS VARCHAR(10))
PRINT 'After Funding End Date Filter: ' + CAST(@funding_count AS VARCHAR(10))
PRINT 'After SETID/FY Filter: ' + CAST(@setid_count AS VARCHAR(10))
PRINT 'After MAX EFFDT Filter: ' + CAST(@effdt_count AS VARCHAR(10))
PRINT 'After MAX EFFSEQ Filter: ' + CAST(@effseq_count AS VARCHAR(10))
PRINT 'After MAX BUDGET_SEQ Filter: ' + CAST(@final_count AS VARCHAR(10))
PRINT 'Final View Records: ' + CAST(@view_count AS VARCHAR(10))
PRINT ''
PRINT '=== QA ANALYSIS COMPLETED ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
GO
