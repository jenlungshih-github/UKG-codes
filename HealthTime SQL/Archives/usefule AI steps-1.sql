
-- Debug: Check specific employee 10658311
SELECT 'Debug: Employee 10658311' as Debug_Step,
    e.EMPLID, e.NAME, e.HR_STATUS, e.MANAGER_EMPLID, e.MANAGER_NAME
FROM health_ods.[RPT].[CURRENT_EMPL_DATA] e
WHERE e.EMPLID = '10127245';

-- Debug: Check manager of employee 10127245
SELECT 'Debug: Manager of 10127245' as Debug_Step,
    m.EMPLID, m.NAME, m.HR_STATUS, m.MANAGER_EMPLID
FROM health_ods.[RPT].[CURRENT_EMPL_DATA] e
    LEFT JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m ON e.MANAGER_EMPLID = m.EMPLID
WHERE e.EMPLID = '10127245';

-- Debug: Check if we have inactive managers first
SELECT TOP 5
    'Step 0: Inactive Managers Check' as Debug_Step,
    COUNT(*) as Record_Count
FROM health_ods.[RPT].[CURRENT_EMPL_DATA]
WHERE HR_STATUS = 'I';

SELECT TOP 5
    'Step 0a: Sample Inactive Managers' as Debug_Step,
    EMPLID, NAME, HR_STATUS, MANAGER_EMPLID
FROM health_ods.[RPT].[CURRENT_EMPL_DATA]
WHERE HR_STATUS = 'I';

-- Create staging tables for better performance
-- Step 1: Create staging table for inactive managers and their employees
IF OBJECT_ID('tempdb..#InactiveManagerEmployees') IS NOT NULL DROP TABLE #InactiveManagerEmployees;

SELECT
    e.emplid,
    e.MANAGER_EMPLID,
    e.MANAGER_NAME,
    m.HR_STATUS as MANAGER_HR_STATUS,
    m.EMPL_RCD as MANAGER_EMPL_RCD
INTO #InactiveManagerEmployees
FROM health_ods.[RPT].[CURRENT_EMPL_DATA] e
    INNER JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON e.MANAGER_EMPLID = m.EMPLID
WHERE e.EMPLID = '10127245' OR m.HR_STATUS = 'I';
-- Include specific employee for debugging

-- Debug Step 1
SELECT 'Step 1: Employees with Inactive Managers - Total Count' as Debug_Step, COUNT(*) as Record_Count
FROM #InactiveManagerEmployees;

SELECT 'Step 1: Employee 10127245 in staging table' as Debug_Step, COUNT(*) as Record_Count
FROM #InactiveManagerEmployees
WHERE emplid = '10127245';

SELECT 'Step 1: Sample records including 10127245' as Debug_Step;
    SELECT TOP 3
        *
    FROM #InactiveManagerEmployees
    WHERE emplid = '10127245'
UNION ALL
    SELECT TOP 2
        *
    FROM #InactiveManagerEmployees
    WHERE emplid <> '10127245';

-- Step 2: Create staging table for hierarchy positions
IF OBJECT_ID('tempdb..#HierarchyPositions') IS NOT NULL DROP TABLE #HierarchyPositions;

SELECT
    ime.emplid,
    ime.MANAGER_EMPLID,
    ime.MANAGER_NAME,
    ime.MANAGER_HR_STATUS,
    HPOSN.LEVEL
INTO #HierarchyPositions
FROM #InactiveManagerEmployees ime
    LEFT JOIN health_ods.[health_ods].[RPT].ORG_HIERARCHY_POSN HPOSN
    ON HPOSN.EMPLID = ime.MANAGER_EMPLID
        AND HPOSN.EMPL_RCD = ime.MANAGER_EMPL_RCD;
-- Removed WHERE HPOSN.LEVEL IS NOT NULL to see all records

-- Debug Step 2
SELECT 'Step 2: All Records with Hierarchy Join - Total Count' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions;

SELECT 'Step 2: Employee 10127245 in hierarchy positions' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions
WHERE emplid = '10127245';

SELECT 'Step 2a: Records with NULL LEVEL - Total' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions
WHERE LEVEL IS NULL;

SELECT 'Step 2a: Employee 10127245 with NULL LEVEL' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions
WHERE LEVEL IS NULL AND emplid = '10127245';

SELECT 'Step 2b: Records with NOT NULL LEVEL - Total' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions
WHERE LEVEL IS NOT NULL;

SELECT 'Step 2b: Employee 10127245 with NOT NULL LEVEL' as Debug_Step, COUNT(*) as Record_Count
FROM #HierarchyPositions
WHERE LEVEL IS NOT NULL AND emplid = '10127245';

SELECT 'Step 2: Sample records including 10127245' as Debug_Step;
    SELECT *
    FROM #HierarchyPositions
    WHERE emplid = '10127245'
UNION ALL
    SELECT TOP 2
        *
    FROM #HierarchyPositions
    WHERE emplid <> '10127245';

-- Step 3: Create manager hierarchy staging table (iterative approach)
IF OBJECT_ID('tempdb..#ManagerHierarchy') IS NOT NULL DROP TABLE #ManagerHierarchy;

CREATE TABLE #ManagerHierarchy
(
    MANAGER_EMPLID VARCHAR(11),
    MANAGER_NAME VARCHAR(50),
    HR_STATUS VARCHAR(1),
    NEXT_MANAGER_EMPLID VARCHAR(11),
    LEVEL_UP INT
);

-- Insert level 1 managers (inactive managers from our main query)
INSERT INTO #ManagerHierarchy
SELECT DISTINCT
    hp.MANAGER_EMPLID,
    hp.MANAGER_NAME,
    hp.MANAGER_HR_STATUS,
    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    1 as LEVEL_UP
FROM #HierarchyPositions hp
    LEFT JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON hp.MANAGER_EMPLID = m.EMPLID;

-- Debug Level 1 insertions
SELECT 'Level 1: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy
WHERE LEVEL_UP = 1;

SELECT 'Level 1: Manager of employee 10127245' as Debug_Step;
SELECT mh.*
FROM #ManagerHierarchy mh
    INNER JOIN #HierarchyPositions hp ON mh.MANAGER_EMPLID = hp.MANAGER_EMPLID
WHERE hp.emplid = '10127245' AND mh.LEVEL_UP = 1;

-- Insert level 2 managers
INSERT INTO #ManagerHierarchy
SELECT DISTINCT
    m.EMPLID as MANAGER_EMPLID,
    m.NAME as MANAGER_NAME,
    m.HR_STATUS,
    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    2 as LEVEL_UP
FROM #ManagerHierarchy mh1
    INNER JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON mh1.NEXT_MANAGER_EMPLID = m.EMPLID
WHERE mh1.LEVEL_UP = 1
    AND mh1.NEXT_MANAGER_EMPLID IS NOT NULL
    AND NOT EXISTS (SELECT 1
    FROM #ManagerHierarchy mh2
    WHERE mh2.MANAGER_EMPLID = m.EMPLID);

-- Debug Level 2 insertions
SELECT 'Level 2: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy
WHERE LEVEL_UP = 2;

SELECT 'Level 2: Hierarchy chain for employee 10127245' as Debug_Step;
SELECT mh.*
FROM #ManagerHierarchy mh
WHERE mh.MANAGER_EMPLID IN (
    SELECT mh2.NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy mh2
        INNER JOIN #HierarchyPositions hp ON mh2.MANAGER_EMPLID = hp.MANAGER_EMPLID
    WHERE hp.emplid = '10127245' AND mh2.LEVEL_UP = 1
) AND mh.LEVEL_UP = 2;

-- Insert level 3 managers
INSERT INTO #ManagerHierarchy
SELECT DISTINCT
    m.EMPLID as MANAGER_EMPLID,
    m.NAME as MANAGER_NAME,
    m.HR_STATUS,
    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    3 as LEVEL_UP
FROM #ManagerHierarchy mh2
    INNER JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON mh2.NEXT_MANAGER_EMPLID = m.EMPLID
WHERE mh2.LEVEL_UP = 2
    AND mh2.NEXT_MANAGER_EMPLID IS NOT NULL
    AND NOT EXISTS (SELECT 1
    FROM #ManagerHierarchy mh3
    WHERE mh3.MANAGER_EMPLID = m.EMPLID);

-- Debug Level 3 insertions
SELECT 'Level 3: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy
WHERE LEVEL_UP = 3;

-- Insert level 4 managers
INSERT INTO #ManagerHierarchy
SELECT DISTINCT
    m.EMPLID as MANAGER_EMPLID,
    m.NAME as MANAGER_NAME,
    m.HR_STATUS,
    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    4 as LEVEL_UP
FROM #ManagerHierarchy mh3
    INNER JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON mh3.NEXT_MANAGER_EMPLID = m.EMPLID
WHERE mh3.LEVEL_UP = 3
    AND mh3.NEXT_MANAGER_EMPLID IS NOT NULL
    AND NOT EXISTS (SELECT 1
    FROM #ManagerHierarchy mh4
    WHERE mh4.MANAGER_EMPLID = m.EMPLID);

-- Debug Level 4 insertions
SELECT 'Level 4: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy
WHERE LEVEL_UP = 4;

-- Insert level 5 managers
INSERT INTO #ManagerHierarchy
SELECT DISTINCT
    m.EMPLID as MANAGER_EMPLID,
    m.NAME as MANAGER_NAME,
    m.HR_STATUS,
    m.MANAGER_EMPLID as NEXT_MANAGER_EMPLID,
    5 as LEVEL_UP
FROM #ManagerHierarchy mh4
    INNER JOIN health_ods.[RPT].[CURRENT_EMPL_DATA] m
    ON mh4.NEXT_MANAGER_EMPLID = m.EMPLID
WHERE mh4.LEVEL_UP = 4
    AND mh4.NEXT_MANAGER_EMPLID IS NOT NULL
    AND NOT EXISTS (SELECT 1
    FROM #ManagerHierarchy mh5
    WHERE mh5.MANAGER_EMPLID = m.EMPLID);

-- Debug Level 5 insertions and complete hierarchy for 10127245
SELECT 'Level 5: Total managers inserted' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy
WHERE LEVEL_UP = 5;

SELECT 'Complete Management Chain for Employee 10127245' as Debug_Step;
WITH
    EmployeeChain
    AS
    (
        SELECT hp.MANAGER_EMPLID
        FROM #HierarchyPositions hp
        WHERE hp.emplid = '10127245'
    )
SELECT mh.LEVEL_UP, mh.MANAGER_EMPLID, mh.MANAGER_NAME, mh.HR_STATUS, mh.NEXT_MANAGER_EMPLID
FROM #ManagerHierarchy mh
WHERE mh.MANAGER_EMPLID IN (SELECT MANAGER_EMPLID
    FROM EmployeeChain)
    OR mh.MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT MANAGER_EMPLID
    FROM EmployeeChain))
    OR mh.MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT MANAGER_EMPLID
    FROM EmployeeChain)))
    OR mh.MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT MANAGER_EMPLID
    FROM EmployeeChain))))
    OR mh.MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT NEXT_MANAGER_EMPLID
    FROM #ManagerHierarchy
    WHERE MANAGER_EMPLID IN (SELECT MANAGER_EMPLID
    FROM EmployeeChain)))))
ORDER BY mh.LEVEL_UP;

-- Final query using staging tables - focus on employee 10127245
SELECT 'Results for Employee 10127245' as Debug_Step;
SELECT TOP 10
    hp.emplid,
    hp.MANAGER_EMPLID,
    hp.MANAGER_NAME,
    hp.MANAGER_HR_STATUS,
    hp.LEVEL
FROM #HierarchyPositions hp
WHERE hp.emplid = '10127245'
ORDER BY hp.emplid;

-- Show all hierarchy levels for debugging
SELECT 'All Hierarchy Levels for 10127245' as Debug_Step;
SELECT
    hp.emplid,
    hp.MANAGER_EMPLID,
    hp.MANAGER_NAME,
    hp.MANAGER_HR_STATUS,
    hp.LEVEL,
    mh.MANAGER_EMPLID as HIERARCHY_MANAGER_EMPLID,
    mh.MANAGER_NAME as HIERARCHY_MANAGER_NAME,
    mh.HR_STATUS as HIERARCHY_MANAGER_HR_STATUS,
    mh.LEVEL_UP
FROM #HierarchyPositions hp
    LEFT JOIN #ManagerHierarchy mh ON hp.MANAGER_EMPLID = mh.MANAGER_EMPLID
WHERE hp.emplid = '10127245'
ORDER BY hp.emplid, mh.LEVEL_UP;

-- General results (all employees)
SELECT 'General Results' as Debug_Step;
SELECT TOP 10
    hp.emplid,
    hp.MANAGER_EMPLID,
    hp.MANAGER_NAME,
    hp.MANAGER_HR_STATUS,
    hp.LEVEL
FROM #HierarchyPositions hp
ORDER BY hp.emplid;

-- Also show some hierarchy data if it exists
SELECT 'Step 3: Manager Hierarchy Data - Total Count' as Debug_Step, COUNT(*) as Record_Count
FROM #ManagerHierarchy;

SELECT 'Step 3: Manager Hierarchy Data - Count by Level' as Debug_Step;
SELECT LEVEL_UP, COUNT(*) as Record_Count
FROM #ManagerHierarchy
GROUP BY LEVEL_UP
ORDER BY LEVEL_UP;

SELECT 'Step 3: Sample hierarchy data for employee 10127245' as Debug_Step;
SELECT TOP 5
    mh.*
FROM #ManagerHierarchy mh
    INNER JOIN #HierarchyPositions hp ON mh.MANAGER_EMPLID = hp.MANAGER_EMPLID
WHERE hp.emplid = '10127245'
ORDER BY mh.LEVEL_UP;

-- Original complex query for comparison
SELECT TOP 10
    hp.emplid,
    hp.MANAGER_EMPLID,
    hp.MANAGER_NAME,
    hp.MANAGER_HR_STATUS,
    hp.LEVEL,
    mh.MANAGER_EMPLID as HIERARCHY_MANAGER_EMPLID,
    mh.MANAGER_NAME as HIERARCHY_MANAGER_NAME,
    mh.HR_STATUS as HIERARCHY_MANAGER_HR_STATUS,
    mh.LEVEL_UP
FROM #HierarchyPositions hp
    LEFT JOIN #ManagerHierarchy mh ON hp.MANAGER_EMPLID = mh.MANAGER_EMPLID
ORDER BY hp.emplid, mh.LEVEL_UP;

-- Cleanup
DROP TABLE #InactiveManagerEmployees;
DROP TABLE #HierarchyPositions;
DROP TABLE #ManagerHierarchy;