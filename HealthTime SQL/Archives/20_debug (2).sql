-- Debug 20.sql - Check CTE results and potential matches

-- Step 1: Check what the CTE returns
WITH
    InactiveManagerHierarchy
    AS
    (
        SELECT
            I.[POSITION_NBR],
            I.[Inactive_EMPLID],
            I.[empl_NAME],
            H.POSITION_NBR_To_Check,
            H.[MANAGER_POSITION_NBR],
            H.[POSN_LEVEL]
        FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
            LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
            ON I.[POSITION_NBR] = H.[POSITION_NBR_To_Check]
        WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
            AND I.[POSITION_NBR] IN ( '40695802')
            AND H.To_Trace_Up_1 = 'no'
    )
SELECT
    'CTE Results:' AS Step,
    POSITION_NBR,
    Inactive_EMPLID,
    empl_NAME,
    POSITION_NBR_To_Check,
    MANAGER_POSITION_NBR,
    POSN_LEVEL
FROM InactiveManagerHierarchy;

-- Step 2: Check if position '40695802' exists in UKG_EMPL_Inactive_Manager
SELECT
    'Inactive Manager Check:' AS Step,
    COUNT(*) AS Count_Found
FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager]
WHERE [POSITION_NBR] = '40695802';

-- Step 3: Check hierarchy data for position '40695802'
SELECT
    'Hierarchy Check:' AS Step,
    COUNT(*) AS Count_Found,
    STRING_AGG(POSN_LEVEL, ', ') AS Levels_Found,
    STRING_AGG(CAST(To_Trace_Up_1 AS VARCHAR), ', ') AS To_Trace_Up_Values
FROM [stage].[UKG_EMPL_Inactive_Manager_Hierarchy]
WHERE [POSITION_NBR_To_Check] = '40695802'
GROUP BY [POSITION_NBR_To_Check];

-- Step 4: Check what employees have Reports to Manager = position that CTE should return
WITH
    InactiveManagerHierarchy
    AS
    (
        SELECT
            I.[POSITION_NBR],
            I.[Inactive_EMPLID],
            I.[empl_NAME],
            H.POSITION_NBR_To_Check,
            H.[MANAGER_POSITION_NBR],
            H.[POSN_LEVEL]
        FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
            LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
            ON I.[POSITION_NBR] = H.[POSITION_NBR_To_Check]
        WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
            AND I.[POSITION_NBR] IN ( '40695802')
            AND H.To_Trace_Up_1 = 'no'
    )
SELECT
    'Potential Matches:' AS Step,
    empl.[Reports to Manager] AS Current_Reports_To,
    CTE.POSITION_NBR_To_Check AS CTE_Position_To_Check,
    CTE.MANAGER_POSITION_NBR AS New_Manager_Position,
    empl.[EMPLID] AS Employee_ID,
    empl.[First Name] + ', ' + empl.[Last Name] AS Employee_Name
FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN InactiveManagerHierarchy CTE
    ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];

-- Step 5: Show all employees reporting to position '40695802' (if any)
SELECT
    'Employees reporting to 40695802:' AS Step,
    [EMPLID],
    [First Name] + ', ' + [Last Name] AS Employee_Name,
    [Reports to Manager]
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE [Reports to Manager] = '40695802';
