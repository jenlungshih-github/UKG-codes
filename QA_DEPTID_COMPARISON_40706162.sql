USE [Health_ODS]
GO

/***************************************************************************************************************************************************************************************************************************************************************
--  Simple DEPTID Comparison for Position: 40706162
--  Author:         Jim Shih
--  Date:           10/30/2025
--  Description:    Simple comparison of DEPTID from latest EFFDT in both tables
***************************************************************************************************************************************************************************************************************************************************************/

DECLARE @POSITION_NBR VARCHAR(20) = '40904118';

PRINT '=== DEPTID COMPARISON FOR POSITION: ' + @POSITION_NBR + ' ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
PRINT ''

-- Get latest DEPTID from PS_POSITION_DATA
DECLARE @pos_deptid VARCHAR(10), @pos_effdt DATETIME;
SELECT TOP 1
    @pos_deptid = POSN1.DEPTID,
    @pos_effdt = POSN1.EFFDT
FROM STABLE.PS_POSITION_DATA POSN1
WHERE POSN1.POSITION_NBR = @POSITION_NBR
ORDER BY POSN1.EFFDT DESC;

-- Get latest DEPTID from PS_DEPT_BUDGET_ERN
DECLARE @budget_deptid VARCHAR(10), @budget_effdt DATETIME;
SELECT TOP 1
    @budget_deptid = F.DEPTID,
    @budget_effdt = F.EFFDT
FROM STABLE.PS_DEPT_BUDGET_ERN F
WHERE F.POSITION_NBR = @POSITION_NBR
ORDER BY F.EFFDT DESC;

-- Show comparison results
PRINT 'LATEST RECORDS COMPARISON:'
PRINT 'PS_POSITION_DATA   -> DEPTID: ' + ISNULL(@pos_deptid, 'NULL') + ' | EFFDT: ' + ISNULL(CONVERT(VARCHAR(10), @pos_effdt, 101), 'NULL')
PRINT 'PS_DEPT_BUDGET_ERN -> DEPTID: ' + ISNULL(@budget_deptid, 'NULL') + ' | EFFDT: ' + ISNULL(CONVERT(VARCHAR(10), @budget_effdt, 101), 'NULL')
PRINT ''

-- DEPTID Comparison
PRINT 'DEPTID COMPARISON:'
IF @pos_deptid = @budget_deptid
    PRINT '✅ DEPTID MATCH: Both tables have the same DEPTID (' + ISNULL(@pos_deptid, 'NULL') + ')'
ELSE
    PRINT '❌ DEPTID MISMATCH: Different DEPTID values between tables'

-- EFFDT Comparison
PRINT ''
PRINT 'EFFDT COMPARISON:'
IF @pos_effdt = @budget_effdt
    PRINT '✅ EFFDT MATCH: Both tables have the same EFFDT (' + ISNULL(CONVERT(VARCHAR(10), @pos_effdt, 101), 'NULL') + ')'
ELSE
    PRINT '❌ EFFDT MISMATCH: Different EFFDT values between tables'

-- Overall Comparison
PRINT ''
PRINT 'OVERALL COMPARISON:'
IF @pos_deptid = @budget_deptid AND @pos_effdt = @budget_effdt
    PRINT '✅ COMPLETE MATCH: Both DEPTID and EFFDT match between tables'
ELSE IF @pos_deptid = @budget_deptid
    PRINT '⚠️  PARTIAL MATCH: DEPTID matches but EFFDT differs'
ELSE IF @pos_effdt = @budget_effdt
    PRINT '⚠️  PARTIAL MATCH: EFFDT matches but DEPTID differs'
ELSE
    PRINT '❌ NO MATCH: Both DEPTID and EFFDT differ between tables'

-- Show side-by-side data
PRINT ''
PRINT 'DETAILED COMPARISON:'
    SELECT
        'PS_POSITION_DATA' AS Source_Table,
        POSN1.POSITION_NBR,
        POSN1.DEPTID,
        POSN1.EFFDT,
        POSN1.EFF_STATUS,
        POSN1.DESCR
    FROM STABLE.PS_POSITION_DATA POSN1
    WHERE POSN1.POSITION_NBR = @POSITION_NBR
        AND POSN1.EFFDT = @pos_effdt

UNION ALL

    SELECT
        'PS_DEPT_BUDGET_ERN' AS Source_Table,
        F.POSITION_NBR,
        F.DEPTID,
        F.EFFDT,
        NULL AS EFF_STATUS,
        NULL AS DESCR
    FROM STABLE.PS_DEPT_BUDGET_ERN F
    WHERE F.POSITION_NBR = @POSITION_NBR
        AND F.EFFDT = @budget_effdt

ORDER BY Source_Table;

PRINT ''
PRINT '=== COMPARISON COMPLETED ==='
PRINT 'Timestamp: ' + CONVERT(VARCHAR(30), GETDATE(), 120)
GO
