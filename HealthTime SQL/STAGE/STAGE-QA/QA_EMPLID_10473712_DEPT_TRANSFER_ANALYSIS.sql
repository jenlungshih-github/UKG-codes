/*
    QA Analysis: EMPLID Department Transfer Detection Issue
    Date: 2025-12-03
    Issue: Employee had position change on 11/23/2025 but not caught by SP_EMPL_DEPT_TRANSFER_build
    
    Purpose: Comprehensive analysis to determine why the department transfer logic 
    is not detecting the position/department change for a specific employee.
    
    Usage: Set @EMPLID parameter to the employee ID you want to analyze
*/

-- Set the EMPLID parameter here
DECLARE @EMPLID VARCHAR(11) = '10473712';
-- Change this value to analyze different employees

-- Step 1: Check raw PS_JOB data for emplid around 11/23/2025
SELECT
    'Step 1: Raw PS_JOB Data for EMPLID ' + @EMPLID AS Analysis_Step,
    'Checking all job records around 11/23/2025' AS Description;

SELECT
    JOB.EMPLID,
    JOB.EMPL_RCD,
    JOB.EFFDT,
    JOB.EFFSEQ,
    JOB.JOB_INDICATOR,
    JOB.DML_IND,
    JOB.HR_STATUS,
    JOB.DEPTID,
    JOB.ACTION,
    JOB.ACTION_DT,
    JOB.jobcode,
    JOB.POSITION_NBR,
    MONTH(JOB.EFFDT) AS EFFDT_MONTH,
    CASE 
        WHEN JOB.EFFDT BETWEEN '7/1/2025' AND GETDATE() THEN 'Within Date Range'
        ELSE 'Outside Date Range'
    END AS Date_Range_Check,
    CASE 
        WHEN JOB.JOB_INDICATOR = 'P' THEN 'Primary Job - INCLUDED'
        ELSE 'Not Primary Job - EXCLUDED'
    END AS Job_Indicator_Check,
    CASE 
        WHEN JOB.DML_IND <> 'D' THEN 'Active Record - INCLUDED'
        ELSE 'Deleted Record - EXCLUDED'
    END AS DML_Check
FROM health_ods.[health_ods].STABLE.PS_JOB JOB
WHERE JOB.EMPLID = @EMPLID
    AND JOB.EFFDT >= '2025-11-01'
-- Look at November data
ORDER BY JOB.EFFDT, JOB.EFFSEQ;

-- Step 2: Check MaxEffdt logic - what records are selected as max effective date per month
SELECT
    'Step 2: MaxEffdt Logic Analysis' AS Analysis_Step,
    'Checking which records are selected as max EFFDT per month' AS Description;

WITH
    MaxEffdt
    AS
    (
        SELECT
            EMPLID,
            EMPL_RCD,
            MAX(EFFDT) AS EFFDT,
            MONTH(EFFDT) AS EFFDT_MONTH,
            COUNT(*) AS Records_In_Month
        FROM health_ods.[health_ods].STABLE.PS_JOB
        WHERE DML_IND <> 'D'
            AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND EMPLID = @EMPLID
        GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
    )
SELECT
    ME.EMPLID,
    ME.EMPL_RCD,
    ME.EFFDT,
    ME.EFFDT_MONTH,
    ME.Records_In_Month,
    JOB.EFFSEQ,
    JOB.JOB_INDICATOR,
    JOB.HR_STATUS,
    JOB.DEPTID,
    JOB.POSITION_NBR,
    JOB.jobcode,
    JOB.ACTION,
    CASE 
        WHEN JOB.JOB_INDICATOR = 'P' AND JOB.DML_IND <> 'D' THEN 'INCLUDED in CTE'
        ELSE 'EXCLUDED from CTE'
    END AS CTE_Inclusion_Status
FROM MaxEffdt ME
    JOIN health_ods.[health_ods].STABLE.PS_JOB JOB
    ON ME.EMPLID = JOB.EMPLID
        AND ME.EMPL_RCD = JOB.EMPL_RCD
        AND ME.EFFDT = JOB.EFFDT
ORDER BY ME.EFFDT, JOB.EFFSEQ;

-- Step 3: Check EFFSEQ filtering - which record has MAX EFFSEQ for each selected date
SELECT
    'Step 3: EFFSEQ Filtering Analysis' AS Analysis_Step,
    'Checking which record has MAX EFFSEQ for each date' AS Description;

WITH
    MaxEffdt
    AS
    (
        SELECT EMPLID, EMPL_RCD, MAX(EFFDT) AS EFFDT
        FROM health_ods.[health_ods].STABLE.PS_JOB
        WHERE DML_IND <> 'D'
            AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND EMPLID = @EMPLID
        GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
    )
SELECT
    JOB.EMPLID,
    JOB.EMPL_RCD,
    JOB.EFFDT,
    JOB.EFFSEQ,
    MAX(JOB2.EFFSEQ) AS Max_EFFSEQ_Available,
    CASE 
        WHEN JOB.EFFSEQ = (SELECT MAX(EFFSEQ)
    FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
    WHERE JOB.EMPLID = JOB2.EMPLID AND JOB.EMPL_RCD = JOB2.EMPL_RCD
        AND JOB.EFFDT = JOB2.EFFDT AND JOB2.DML_IND <> 'D') 
        THEN 'MAX EFFSEQ - INCLUDED'
        ELSE 'Not MAX EFFSEQ - EXCLUDED'
    END AS EFFSEQ_Filter_Status,
    JOB.JOB_INDICATOR,
    JOB.HR_STATUS,
    JOB.DEPTID,
    JOB.POSITION_NBR,
    JOB.ACTION
FROM MaxEffdt MEP
    JOIN health_ods.[health_ods].STABLE.PS_JOB JOB
    ON MEP.EMPLID = JOB.EMPLID
        AND MEP.EMPL_RCD = JOB.EMPL_RCD
        AND MEP.EFFDT = JOB.EFFDT
    JOIN health_ods.[health_ods].STABLE.PS_JOB JOB2
    ON JOB.EMPLID = JOB2.EMPLID
        AND JOB.EMPL_RCD = JOB2.EMPL_RCD
        AND JOB.EFFDT = JOB2.EFFDT
WHERE JOB.DML_IND <> 'D' AND JOB2.DML_IND <> 'D'
GROUP BY JOB.EMPLID, JOB.EMPL_RCD, JOB.EFFDT, JOB.EFFSEQ, JOB.JOB_INDICATOR, 
         JOB.HR_STATUS, JOB.DEPTID, JOB.POSITION_NBR, JOB.ACTION
ORDER BY JOB.EFFDT, JOB.EFFSEQ;

-- Step 4: Check Department Hierarchy JOIN
SELECT
    'Step 4: Department Hierarchy JOIN Analysis' AS Analysis_Step,
    'Checking if DEPTID exists in DEPARTMENT_HIERARCHY table' AS Description;

WITH
    MaxEffdt
    AS
    (
        SELECT EMPLID, EMPL_RCD, MAX(EFFDT) AS EFFDT
        FROM health_ods.[health_ods].STABLE.PS_JOB
        WHERE DML_IND <> 'D'
            AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND EMPLID = @EMPLID
        GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
    )
SELECT
    JOB.EMPLID,
    JOB.EMPL_RCD,
    JOB.EFFDT,
    JOB.DEPTID,
    DH.DEPTID AS DH_DEPTID,
    DH.VC_CODE,
    DH.VC_NAME,
    CASE 
        WHEN DH.DEPTID IS NOT NULL THEN 'DEPARTMENT FOUND - INCLUDED'
        ELSE 'DEPARTMENT NOT FOUND - EXCLUDED'
    END AS Dept_Hierarchy_Status,
    JOB.HR_STATUS,
    JOB.POSITION_NBR,
    JOB.ACTION
FROM MaxEffdt MEP
    JOIN health_ods.[health_ods].STABLE.PS_JOB JOB
    ON MEP.EMPLID = JOB.EMPLID
        AND MEP.EMPL_RCD = JOB.EMPL_RCD
        AND MEP.EFFDT = JOB.EFFDT
    LEFT JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH
    ON JOB.DEPTID = DH.DEPTID
WHERE JOB.JOB_INDICATOR = 'P'
    AND JOB.DML_IND <> 'D'
    AND JOB.EFFSEQ = (
        SELECT MAX(EFFSEQ)
    FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
    WHERE JOB.EMPLID = JOB2.EMPLID
        AND JOB.EMPL_RCD = JOB2.EMPL_RCD
        AND JOB.EFFDT = JOB2.EFFDT
        AND JOB2.DML_IND <> 'D'
    )
ORDER BY JOB.EFFDT;

-- Step 5: Check LEAD() Window Function Results
SELECT
    'Step 5: LEAD() Window Function Analysis' AS Analysis_Step,
    'Checking what NEXT_ values are calculated by window functions' AS Description;

WITH
    MaxEffdt
    AS
    (
        SELECT EMPLID, EMPL_RCD, MAX(EFFDT) AS EFFDT
        FROM health_ods.[health_ods].STABLE.PS_JOB
        WHERE DML_IND <> 'D'
            AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND EMPLID = @EMPLID
        GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
    ),
    EMPL_DEPT_TRANSFERS
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            DH.VC_CODE,
            JOB.HR_STATUS,
            JOB.DEPTID,
            JOB.EFFDT,
            JOB.ACTION,
            JOB.jobcode,
            JOB.POSITION_NBR,
            LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID,
            LEAD(JOB.EFFDT) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_EFFDT,
            LEAD(DH.VC_CODE) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_CODE,
            LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_HR_STATUS,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_POSITION_NBR,
            CASE 
            WHEN JOB.DEPTID != LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT)
            THEN 'DEPARTMENT CHANGED'
            ELSE 'NO DEPARTMENT CHANGE'
        END AS Dept_Change_Status,
            CASE 
            WHEN JOB.POSITION_NBR != LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT)
            THEN 'POSITION CHANGED'
            ELSE 'NO POSITION CHANGE'
        END AS Position_Change_Status
        FROM health_ods.[health_ods].STABLE.PS_JOB JOB
            JOIN MaxEffdt MEP
            ON JOB.EMPLID = MEP.EMPLID
                AND JOB.EMPL_RCD = MEP.EMPL_RCD
                AND JOB.EFFDT = MEP.EFFDT
            JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH
            ON JOB.DEPTID = DH.DEPTID
        WHERE JOB.JOB_INDICATOR = 'P'
            AND JOB.DML_IND <> 'D'
            AND JOB.EFFSEQ = (
            SELECT MAX(EFFSEQ)
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
            WHERE JOB.EMPLID = JOB2.EMPLID
                AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                AND JOB.EFFDT = JOB2.EFFDT
                AND JOB2.DML_IND <> 'D'
        )
    )
SELECT *
FROM EMPL_DEPT_TRANSFERS
ORDER BY EFFDT;

-- Step 6: Check Filter Conditions
SELECT
    'Step 6: Filter Conditions Analysis' AS Analysis_Step,
    'Checking which filter conditions are preventing inclusion' AS Description;

WITH
    MaxEffdt
    AS
    (
        SELECT EMPLID, EMPL_RCD, MAX(EFFDT) AS EFFDT
        FROM health_ods.[health_ods].STABLE.PS_JOB
        WHERE DML_IND <> 'D'
            AND EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND EMPLID = @EMPLID
        GROUP BY EMPLID, EMPL_RCD, MONTH(EFFDT)
    ),
    EMPL_DEPT_TRANSFERS
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            DH.VC_CODE,
            JOB.HR_STATUS,
            JOB.DEPTID,
            JOB.EFFDT,
            JOB.ACTION,
            JOB.jobcode,
            JOB.POSITION_NBR,
            LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID,
            LEAD(DH.VC_CODE) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_VC_CODE,
            LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_HR_STATUS
        FROM health_ods.[health_ods].STABLE.PS_JOB JOB
            JOIN MaxEffdt MEP
            ON JOB.EMPLID = MEP.EMPLID
                AND JOB.EMPL_RCD = MEP.EMPL_RCD
                AND JOB.EFFDT = MEP.EFFDT
            JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH
            ON JOB.DEPTID = DH.DEPTID
        WHERE JOB.JOB_INDICATOR = 'P'
            AND JOB.DML_IND <> 'D'
            AND JOB.EFFSEQ = (
            SELECT MAX(EFFSEQ)
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
            WHERE JOB.EMPLID = JOB2.EMPLID
                AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                AND JOB.EFFDT = JOB2.EFFDT
                AND JOB2.DML_IND <> 'D'
        )
    )
SELECT
    *,
    CASE 
        WHEN DEPTID != NEXT_DEPTID THEN 'PASS: Department Changed'
        ELSE 'FAIL: No Department Change'
    END AS Filter1_Dept_Change,
    CASE 
        WHEN NEXT_DEPTID IS NOT NULL THEN 'PASS: NEXT_DEPTID Not Null'
        ELSE 'FAIL: NEXT_DEPTID is Null'
    END AS Filter2_Next_Dept_NotNull,
    CASE 
        WHEN HR_STATUS = 'A' THEN 'PASS: Current HR_STATUS = A'
        ELSE 'FAIL: Current HR_STATUS != A'
    END AS Filter3_Current_Active,
    CASE 
        WHEN NEXT_HR_STATUS = 'A' THEN 'PASS: Next HR_STATUS = A'
        ELSE 'FAIL: Next HR_STATUS != A'
    END AS Filter4_Next_Active,
    CASE 
        WHEN VC_CODE = 'VCHSH' OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280'))
        THEN 'PASS: Source Dept Eligible (MED CENTER or PHSO)'
        ELSE 'FAIL: Source Dept Not Eligible'
    END AS Filter5_Source_Dept_Eligible,
    CASE 
        WHEN DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776')
        THEN 'FAIL: Excluded DEPTID/JOBCODE Combination'
        ELSE 'PASS: Not Excluded DEPTID/JOBCODE'
    END AS Filter6_Exclusion_Check,
    CASE 
        WHEN NEXT_VC_CODE NOT IN ('VCHSH') AND NOT (NEXT_DEPTID BETWEEN '002000' AND '002999' AND NEXT_DEPTID NOT IN ('002230','002231','002280'))
        THEN 'PASS: Target Dept Eligible (Not MED CENTER, Not PHSO)'
        ELSE 'FAIL: Target Dept Not Eligible (Transferring to MED CENTER or PHSO)'
    END AS Filter7_Target_Dept_Eligible,
    CASE 
        WHEN DEPTID != NEXT_DEPTID
        AND NEXT_DEPTID IS NOT NULL
        AND HR_STATUS = 'A'
        AND NEXT_HR_STATUS = 'A'
        AND (VC_CODE = 'VCHSH' OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280')))
        AND NOT (DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776'))
        AND (NEXT_VC_CODE NOT IN ('VCHSH') AND NOT (NEXT_DEPTID BETWEEN '002000' AND '002999' AND NEXT_DEPTID NOT IN ('002230','002231','002280')))
        THEN 'INCLUDED: All Filters Pass'
        ELSE 'EXCLUDED: One or More Filters Fail'
    END AS Final_Filter_Result
FROM EMPL_DEPT_TRANSFERS
ORDER BY EFFDT;

-- Step 7: Summary Analysis
SELECT
    'Step 7: Summary and Recommendations' AS Analysis_Step,
    'Key findings and potential issues' AS Description;

-- Summary recommendations
SELECT
    'SUMMARY RECOMMENDATIONS:' AS Recommendation,
    '1. Check if 11/23/2025 record has correct EFFDT grouping' AS Step1,
    '2. Verify DEPARTMENT_HIERARCHY table has DEPTID mapping' AS Step2,
    '3. Check if department change actually occurred between records' AS Step3,
    '4. Verify HR_STATUS is A for both current and next records' AS Step4,
    '5. Check if source/target departments meet eligibility criteria' AS Step5;
