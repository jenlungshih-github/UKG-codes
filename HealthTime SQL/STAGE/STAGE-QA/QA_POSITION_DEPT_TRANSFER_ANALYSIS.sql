/*
    QA Analysis: Position-Based Department Transfer Detection Issue
    Date: 2025-12-04
    Issue: Position change not being caught by SP_EMPL_DEPT_TRANSFER_build
    
    Purpose: Comprehensive analysis to determine why position-based department transfer logic 
    is not detecting changes for a specific employee and position.
    
    Usage: Set @EMPLID and @POSITION_NBR parameters to analyze specific position changes
*/

-- Set the parameters here
DECLARE @EMPLID VARCHAR(11) = '10473712';
-- Change this value to analyze different employees
DECLARE @POSITION_NBR VARCHAR(10) = '40697565';
-- Change this value to analyze different positions
DECLARE @NEXT_POSITION_NBR VARCHAR(10) = '41072726';
-- Next position number for transition analysis

-- Step 1: Check raw PS_JOB data for emplid and position_nbr
SELECT
    'Step 1: Raw PS_JOB Data for EMPLID ' + @EMPLID + ' and POSITION_NBR ' + @POSITION_NBR AS Analysis_Step,
    'Checking all job records with position changes' AS Description;

SELECT
    JOB.EMPLID,
    JOB.EMPL_RCD,
    JOB.EFFDT,
    JOB.EFFSEQ,
    JOB.JOB_INDICATOR,
    JOB.DML_IND,
    JOB.HR_STATUS,
    JOB.POSITION_NBR,
    JOB.DEPTID,
    JOB.ACTION,
    JOB.ACTION_DT,
    JOB.jobcode,
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
    AND (JOB.POSITION_NBR = @POSITION_NBR OR JOB.EFFDT >= '2025-11-01')
ORDER BY JOB.EFFDT, JOB.EFFSEQ;

-- Step 2: Check Position Number Changes Over Time
SELECT
    'Step 2: Position Number Change Analysis' AS Analysis_Step,
    'Tracking position changes and associated department changes' AS Description;

WITH
    PositionHistory
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            JOB.EFFDT,
            JOB.EFFSEQ,
            JOB.POSITION_NBR,
            JOB.DEPTID,
            JOB.HR_STATUS,
            JOB.ACTION,
            JOB.JOB_INDICATOR,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_POSITION_NBR,
            LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_DEPTID,
            LEAD(JOB.EFFDT) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_EFFDT,
            LEAD(JOB.HR_STATUS) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_HR_STATUS
        FROM health_ods.[health_ods].STABLE.PS_JOB JOB
        WHERE JOB.EMPLID = @EMPLID
            AND JOB.DML_IND <> 'D'
            --AND JOB.EFFDT BETWEEN '7/1/2025' AND GETDATE()
            AND JOB.JOB_INDICATOR = 'P'
            AND JOB.EFFSEQ = (
            SELECT MAX(EFFSEQ)
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
            WHERE JOB.EMPLID = JOB2.EMPLID
                AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                AND JOB.EFFDT = JOB2.EFFDT
                AND JOB2.DML_IND <> 'D'
        )
    ),
    Nov23Transition
    AS
    (
        SELECT
            POSITION_NBR AS From_Position,
            NEXT_POSITION_NBR AS To_Position,
            EFFDT,
            NEXT_EFFDT,
            ROW_NUMBER() OVER (ORDER BY EFFDT, EFFSEQ) as Record_Number
        FROM PositionHistory
        WHERE POSITION_NBR = @POSITION_NBR
            AND NEXT_POSITION_NBR IS NOT NULL
            AND POSITION_NBR != NEXT_POSITION_NBR
        -- Only position changes
    ),
    FirstPositionSwitch
    AS
    (
        SELECT TOP 1
            *
        FROM Nov23Transition
        ORDER BY EFFDT
    )
SELECT
    PH.*,
    ROW_NUMBER() OVER (ORDER BY PH.EFFDT, PH.EFFSEQ) as Record_Number,
    CASE 
        WHEN PH.POSITION_NBR != PH.NEXT_POSITION_NBR THEN 'POSITION CHANGED'
        ELSE 'NO POSITION CHANGE'
    END AS Position_Change_Status,
    CASE 
        WHEN PH.DEPTID != PH.NEXT_DEPTID THEN 'DEPARTMENT CHANGED'
        ELSE 'NO DEPARTMENT CHANGE'
    END AS Dept_Change_Status,
    CASE 
        WHEN PH.POSITION_NBR != PH.NEXT_POSITION_NBR AND PH.DEPTID = PH.NEXT_DEPTID THEN 'POSITION CHANGED - SAME DEPT'
        WHEN PH.POSITION_NBR != PH.NEXT_POSITION_NBR AND PH.DEPTID != PH.NEXT_DEPTID THEN 'POSITION AND DEPT CHANGED'
        WHEN PH.POSITION_NBR = PH.NEXT_POSITION_NBR AND PH.DEPTID != PH.NEXT_DEPTID THEN 'DEPT CHANGED - SAME POSITION'
        ELSE 'NO CHANGES'
    END AS Change_Type_Analysis,
    CASE 
        WHEN PH.POSITION_NBR = FPS.From_Position AND PH.NEXT_POSITION_NBR = FPS.To_Position
        THEN 'RECORD #23: FIRST POSITION SWITCH - ' + @POSITION_NBR + ' → ' + ISNULL(PH.NEXT_POSITION_NBR, 'NULL')
        WHEN PH.POSITION_NBR = @POSITION_NBR AND PH.NEXT_POSITION_NBR IS NOT NULL AND PH.POSITION_NBR != PH.NEXT_POSITION_NBR
        THEN 'Position Change: ' + @POSITION_NBR + ' → ' + PH.NEXT_POSITION_NBR
        ELSE 'Other transition'
    END AS Nov23_Transition_Flag,
    FPS.To_Position AS First_Position_Switch_Target
FROM PositionHistory PH
    CROSS JOIN FirstPositionSwitch FPS
ORDER BY PH.EFFDT, PH.EFFSEQ;

-- Step 3: Check Department Hierarchy for Position Number
SELECT
    'Step 3: Department Hierarchy for Position Number ' + @POSITION_NBR AS Analysis_Step,
    'Checking if position exists in DEPARTMENT_HIERARCHY table' AS Description;

SELECT DISTINCT
    JOB.EFFDT,
    JOB.POSITION_NBR,
    DH.DEPTID,
    DH.VC_CODE,
    DH.VC_NAME,
    CASE 
        WHEN DH.VC_CODE = 'VCHSH' THEN 'MED CENTER - Source Eligible'
        WHEN DH.DEPTID BETWEEN '002000' AND '002999' AND DH.DEPTID NOT IN ('002230','002231','002280') THEN 'PHSO - Source Eligible'
        ELSE 'NOT Source Eligible'
    END AS Source_Eligibility_Status
FROM health_ods.[health_ods].STABLE.PS_JOB JOB
    JOIN health_ods.[health_ods].RPT.DEPARTMENT_HIERARCHY DH ON JOB.DEPTID = DH.DEPTID
WHERE JOB.EMPLID = @EMPLID
    AND JOB.POSITION_NBR = @POSITION_NBR
    AND JOB.DML_IND <> 'D'
--AND JOB.EFFDT BETWEEN '7/1/2025' AND GETDATE()
ORDER BY JOB.EFFDT DESC;

-- Step 4: Monthly Grouping Analysis with Position Focus
SELECT
    'Step 4: Monthly Grouping Analysis with Position Focus' AS Analysis_Step,
    'Checking how monthly MAX(EFFDT) affects position-based changes' AS Description;

WITH
    MaxEffdtByMonth
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
    ),
    MonthlyPositionChanges
    AS
    (
        SELECT
            ME.EMPLID,
            ME.EMPL_RCD,
            ME.EFFDT,
            ME.EFFDT_MONTH,
            ME.Records_In_Month,
            JOB.POSITION_NBR,
            JOB.DEPTID,
            JOB.HR_STATUS,
            JOB.ACTION,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_POSITION_NBR,
            LEAD(JOB.DEPTID) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_DEPTID
        FROM MaxEffdtByMonth ME
            JOIN health_ods.[health_ods].STABLE.PS_JOB JOB
            ON ME.EMPLID = JOB.EMPLID
                AND ME.EMPL_RCD = JOB.EMPL_RCD
                AND ME.EFFDT = JOB.EFFDT
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
        WHEN POSITION_NBR = @POSITION_NBR THEN 'TARGET POSITION FOUND'
        ELSE 'OTHER POSITION'
    END AS Position_Target_Match,
    CASE 
        WHEN POSITION_NBR != NEXT_POSITION_NBR THEN 'POSITION CHANGE DETECTED'
        ELSE 'NO POSITION CHANGE'
    END AS Position_Change_Detection,
    CASE 
        WHEN DEPTID != NEXT_DEPTID THEN 'DEPT CHANGE DETECTED'
        ELSE 'NO DEPT CHANGE'
    END AS Dept_Change_Detection
FROM MonthlyPositionChanges
ORDER BY EFFDT;

-- Step 5: Transfer Filter Analysis for Position-Based Changes
SELECT
    'Step 5: Transfer Filter Analysis for Position-Based Changes' AS Analysis_Step,
    'Checking if position-based changes pass all transfer filters' AS Description;

-- First, dynamically discover the FIRST position switch for position 40697565
DECLARE @DYNAMIC_NEXT_POSITION_NBR VARCHAR(10);

WITH
    AllPositionHistory
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            JOB.EFFDT,
            JOB.EFFSEQ,
            JOB.POSITION_NBR,
            JOB.DEPTID,
            JOB.HR_STATUS,
            JOB.ACTION,
            JOB.jobcode,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_POSITION_NBR
        FROM health_ods.[health_ods].STABLE.PS_JOB JOB
        WHERE JOB.EMPLID = @EMPLID
            AND JOB.DML_IND <> 'D'
            AND JOB.JOB_INDICATOR = 'P'
            AND JOB.EFFSEQ = (
            SELECT MAX(EFFSEQ)
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
            WHERE JOB.EMPLID = JOB2.EMPLID
                AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                AND JOB.EFFDT = JOB2.EFFDT
                AND JOB2.DML_IND <> 'D'
        )
    ),
    FirstPositionSwitch
    AS
    (
        SELECT TOP 1
            NEXT_POSITION_NBR AS Next_Position
        FROM AllPositionHistory
        WHERE POSITION_NBR = @POSITION_NBR
            AND NEXT_POSITION_NBR IS NOT NULL
            AND POSITION_NBR != NEXT_POSITION_NBR
        ORDER BY EFFDT, EFFSEQ
    )
SELECT @DYNAMIC_NEXT_POSITION_NBR = Next_Position
FROM FirstPositionSwitch;

-- Show the discovered FIRST position switch (Record #23 equivalent)
SELECT
    'DISCOVERED FIRST POSITION SWITCH:' AS Info_Type,
    @POSITION_NBR AS From_Position,
    ISNULL(@DYNAMIC_NEXT_POSITION_NBR, 'NOT FOUND') AS To_Position,
    'First position change from ' + @POSITION_NBR + ' to ' + ISNULL(@DYNAMIC_NEXT_POSITION_NBR, 'NOT FOUND') + ' (this is what current logic misses)' AS Description;

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
    PositionTransfers
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            DH.VC_CODE,
            JOB.HR_STATUS,
            JOB.DEPTID,
            JOB.POSITION_NBR,
            JOB.EFFDT,
            JOB.ACTION,
            JOB.jobcode,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT) AS NEXT_POSITION_NBR,
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
    -- Position-based change detection
    CASE 
        WHEN POSITION_NBR != NEXT_POSITION_NBR THEN 'PASS: Position Changed'
        ELSE 'INFO: Position Same'
    END AS Position_Change_Check,
    -- Department-based change detection (original logic)
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
    -- Combined filter result (original department-based logic)
    CASE 
        WHEN DEPTID != NEXT_DEPTID
        AND NEXT_DEPTID IS NOT NULL
        AND HR_STATUS = 'A'
        AND NEXT_HR_STATUS = 'A'
        AND (VC_CODE = 'VCHSH' OR (DEPTID BETWEEN '002000' AND '002999' AND DEPTID NOT IN ('002230','002231','002280')))
        AND NOT (DEPTID IN ('002053','002056','003919') AND JOBCODE IN ('000770','000771','000772','000775','000776'))
        AND (NEXT_VC_CODE NOT IN ('VCHSH') AND NOT (NEXT_DEPTID BETWEEN '002000' AND '002999' AND NEXT_DEPTID NOT IN ('002230','002231','002280')))
        THEN 'INCLUDED: All Filters Pass (Dept Change)'
        ELSE 'EXCLUDED: One or More Filters Fail (Dept Change)'
    END AS Final_Dept_Filter_Result,
    -- Analysis of why position changes might not be detected
    CASE 
        WHEN POSITION_NBR = @POSITION_NBR THEN 'TARGET POSITION RECORD (FROM)'
        WHEN NEXT_POSITION_NBR = @POSITION_NBR THEN 'RECORD BEFORE TARGET POSITION'
        WHEN POSITION_NBR = @DYNAMIC_NEXT_POSITION_NBR THEN 'TARGET POSITION RECORD (TO)'
        WHEN NEXT_POSITION_NBR = @DYNAMIC_NEXT_POSITION_NBR THEN 'RECORD TRANSITIONING TO TARGET'
        WHEN POSITION_NBR = @POSITION_NBR AND NEXT_POSITION_NBR = @DYNAMIC_NEXT_POSITION_NBR THEN 'EXACT TRANSITION MATCH - FIRST POSITION SWITCH'
        ELSE 'OTHER POSITION RECORD'
    END AS Position_Target_Analysis,
    -- Specific analysis for the first position switch (Record #23 equivalent)
    CASE 
        WHEN POSITION_NBR = @POSITION_NBR AND NEXT_POSITION_NBR = @DYNAMIC_NEXT_POSITION_NBR 
        THEN 'FOUND: First Position Switch from ' + @POSITION_NBR + ' to ' + @DYNAMIC_NEXT_POSITION_NBR + ' (Record #23 equivalent)'
        WHEN POSITION_NBR = @POSITION_NBR AND NEXT_POSITION_NBR IS NULL
        THEN 'WARNING: Position ' + @POSITION_NBR + ' has no NEXT position (last record)'
        WHEN POSITION_NBR = @POSITION_NBR AND NEXT_POSITION_NBR != @DYNAMIC_NEXT_POSITION_NBR
        THEN 'INFO: Position ' + @POSITION_NBR + ' transitions to different position: ' + ISNULL(NEXT_POSITION_NBR, 'NULL')
        ELSE 'Not relevant to first position switch'
    END AS Transition_Analysis
FROM PositionTransfers
ORDER BY EFFDT;

-- Step 6: Summary Analysis for Position-Based Changes
SELECT
    'Step 6: Summary Analysis for Position-Based Changes' AS Analysis_Step,
    'Key findings about position vs department change detection' AS Description;

-- Get the first position switch for summary
DECLARE @SUMMARY_NEXT_POSITION VARCHAR(10);
WITH
    PositionHistoryWithLead
    AS
    (
        SELECT
            JOB.EMPLID,
            JOB.EMPL_RCD,
            JOB.EFFDT,
            JOB.EFFSEQ,
            JOB.POSITION_NBR,
            JOB.DEPTID,
            JOB.HR_STATUS,
            JOB.ACTION,
            JOB.jobcode,
            LEAD(JOB.POSITION_NBR) OVER (PARTITION BY JOB.EMPLID, JOB.EMPL_RCD ORDER BY JOB.EFFDT, JOB.EFFSEQ) AS NEXT_POSITION_NBR
        FROM health_ods.[health_ods].STABLE.PS_JOB JOB
        WHERE JOB.EMPLID = @EMPLID
            AND JOB.POSITION_NBR = @POSITION_NBR
            AND JOB.DML_IND <> 'D'
            AND JOB.JOB_INDICATOR = 'P'
            AND JOB.EFFSEQ = (
            SELECT MAX(EFFSEQ)
            FROM health_ods.[health_ods].STABLE.PS_JOB JOB2
            WHERE JOB.EMPLID = JOB2.EMPLID
                AND JOB.EMPL_RCD = JOB2.EMPL_RCD
                AND JOB.EFFDT = JOB2.EFFDT
                AND JOB2.DML_IND <> 'D'
        )
    ),
    FirstPositionSwitch
    AS
    (
        SELECT TOP 1
            NEXT_POSITION_NBR AS Next_Position
        FROM PositionHistoryWithLead
        WHERE NEXT_POSITION_NBR IS NOT NULL
            AND POSITION_NBR != NEXT_POSITION_NBR
        ORDER BY EFFDT, EFFSEQ
    )
SELECT @SUMMARY_NEXT_POSITION = Next_Position
FROM FirstPositionSwitch;

-- Summary recommendations
SELECT
    'POSITION-BASED TRANSFER ANALYSIS SUMMARY:' AS Analysis_Type,
    'Current logic only detects DEPARTMENT changes, not POSITION changes' AS Key_Finding,
    'First position switch from Position ' + @POSITION_NBR + ' to ' + ISNULL(@SUMMARY_NEXT_POSITION, 'UNKNOWN') + ' (Record #23 equivalent)' AS First_Position_Switch,
    'Position-only transitions are NOT detected by current department-focused logic' AS Position_Issue,
    'Consider adding POSITION_NBR change detection to transfer logic' AS Recommendation1,
    'Monthly grouping may eliminate intermediate position changes' AS Recommendation2,
    'Position changes without department changes should trigger transfer detection' AS Recommendation3;
