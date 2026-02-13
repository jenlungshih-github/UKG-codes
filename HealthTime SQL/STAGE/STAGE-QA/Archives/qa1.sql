-- Debug Query: Why didn't SP set Manager Flag to 'F' for emplid=10406844?
-- This query traces through the SP logic step by step

DECLARE @emplid VARCHAR(20) = '10374830';

PRINT '=== STEP 1: Check if position was initially identified as vacant ===';

-- Replicate the VacantPositions CTE logic from the SP
WITH
    TERMINATED_empl
    AS
    (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
        WHERE [hr_status]='I'
    ),
    mPOSN_Manager_Flag_To_Update_To_T
    AS
    (
        SELECT E.emplid, E.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
            INNER JOIN TERMINATED_empl TE
            ON E.position_nbr = TE.reports_to
    ),
    VacantPositions
    AS
    (
        SELECT DISTINCT
            mPOSN.[position_nbr]
        FROM (
        SELECT emplid, [position_nbr], FTE, [Hire Date]
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
            WHERE [Manager Flag]='T'
    ) mPOSN
            INNER JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
            ON mPOSN.position_nbr = empl.[POSITION_REPORTS_TO]
        WHERE empl.MANAGER_EMPLID IS NOT NULL
        GROUP BY mPOSN.[position_nbr]
        HAVING SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) = 0
    )
SELECT
    'Position Analysis for Employee' as Question,
    EMP.position_nbr as Position_Number,
    EMP.[Manager Flag] as Current_Manager_Flag,
    EMP.FTE as FTE_Percentage,
    EMP.[Hire Date] as Hire_Date,
    CASE WHEN VP.position_nbr IS NOT NULL 
         THEN 'YES - Should have been set to F in first update'
         ELSE 'NO - Position was not identified as vacant'
    END as Was_Identified_As_Vacant,
    VP.position_nbr as Vacant_Position_Match
FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] EMP
    LEFT JOIN VacantPositions VP ON EMP.position_nbr = VP.position_nbr
WHERE EMP.emplid = @emplid
ORDER BY EMP.position_nbr;

PRINT '=== STEP 2: Check if position has terminated employees (second update) ===';

-- Check the second update logic by position
SELECT
    'Terminated Reports Analysis' as Question,
    EMP.position_nbr as Position_Number,
    EMP.[Manager Flag] as Current_Manager_Flag,
    EMP.FTE as FTE_Percentage,
    EMP.[Hire Date] as Hire_Date,
    CASE WHEN EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] TE
    WHERE TE.reports_to = EMP.position_nbr
        AND TE.[hr_status]='I'
        AND TE.emplid != @emplid
    ) THEN 'YES - Second update sets Manager Flag back to T'
      ELSE 'NO - No terminated reports found'
    END as Has_Terminated_Reports,
    (SELECT COUNT(*)
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] TE
    WHERE TE.reports_to = EMP.position_nbr
        AND TE.[hr_status]='I'
        AND TE.emplid != @emplid
    ) as Terminated_Reports_Count
FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] EMP
WHERE EMP.emplid = @emplid
ORDER BY EMP.position_nbr;

PRINT '=== STEP 3: Detailed analysis ===';

-- Show the terminated employees causing the issue by position
SELECT
    'Terminated Employees by Position' as Analysis,
    EMP.position_nbr as Manager_Position,
    EMP.[Manager Flag] as Manager_Flag,
    EMP.FTE as Manager_FTE_Percentage,
    EMP.[Hire Date] as Manager_Hire_Date,
    TE.emplid as Terminated_Emplid,
    TE.[First Name] + ' ' + TE.[Last Name] as Terminated_Employee,
    TE.FTE as Terminated_Employee_FTE,
    TE.[Hire Date] as Terminated_Employee_Hire_Date,
    TE.reports_to as Reports_To_Position,
    TE.[termination_dt] as Termination_Date,
    'This causes Manager Flag to be reset to T in the second update' as Explanation
FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] EMP
    INNER JOIN [dbo].[UKG_EMPLOYEE_DATA_TEMP] TE ON EMP.position_nbr = TE.reports_to
WHERE EMP.emplid = @emplid
    AND TE.[hr_status] = 'I'
    AND TE.emplid != @emplid
ORDER BY EMP.position_nbr, TE.emplid;

PRINT '=== CONCLUSION ===';

SELECT
    'Position-by-Position Analysis' as Conclusion,
    EMP.position_nbr as Position_Number,
    EMP.[Manager Flag] as Current_Manager_Flag,
    EMP.FTE as FTE_Percentage,
    EMP.[Hire Date] as Hire_Date,
    CASE
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] RPT
    WHERE RPT.reports_to = EMP.position_nbr
        AND RPT.hr_status = 'I'
        AND RPT.emplid != @emplid
        ) THEN 'SP BUG: Position has terminated reports, so second update overrides first update and sets Manager Flag back to T'
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] RPT
    WHERE RPT.reports_to = EMP.position_nbr
        AND RPT.hr_status = 'A'
        AND RPT.emplid != @emplid
        ) THEN 'Position has active reports - Manager Flag should be T'
        ELSE 'Position has no reports - Manager Flag should be F'
    END as Explanation,
    (SELECT COUNT(*)
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] RPT
    WHERE RPT.reports_to = EMP.position_nbr AND RPT.hr_status = 'A' AND RPT.emplid != @emplid) as Active_Reports_Count,
    (SELECT COUNT(*)
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] RPT
    WHERE RPT.reports_to = EMP.position_nbr AND RPT.hr_status = 'I' AND RPT.emplid != @emplid) as Terminated_Reports_Count
FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] EMP
WHERE EMP.emplid = @emplid
ORDER BY EMP.position_nbr;