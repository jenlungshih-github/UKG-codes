-- Debug Query: Why didn't SP set Manager Flag to 'F' for emplid=10406844?
-- This query traces through the SP logic step by step

DECLARE @emplid VARCHAR(20) = '10406844';

PRINT '=== STEP 1: Check if position was initially identified as vacant ===';

-- Replicate the VacantPositions CTE logic from the SP
WITH
    TERMINATED_empl
    AS
    (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
    ),
    mPOSN_Manager_Flag_To_Update_To_T
    AS
    (
        SELECT E.emplid, E.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA] E
            INNER JOIN TERMINATED_empl TE
            ON E.position_nbr = TE.reports_to
    ),
    VacantPositions
    AS
    (
        SELECT DISTINCT
            mPOSN.[position_nbr]
        FROM (
        SELECT emplid, [position_nbr]
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE [Manager Flag]='T'
    ) mPOSN
            INNER JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
            ON mPOSN.position_nbr = empl.[POSITION_REPORTS_TO]
        WHERE empl.MANAGER_EMPLID IS NOT NULL
        GROUP BY mPOSN.[position_nbr]
        HAVING SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) = 0
    )
SELECT
    'Was position identified as vacant?' as Question,
    CASE WHEN EXISTS (SELECT 1
    FROM VacantPositions
    WHERE position_nbr = (SELECT position_nbr
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE emplid = @emplid))
         THEN 'YES - Should have been set to F in first update'
         ELSE 'NO - Position was not identified as vacant'
    END as Answer,
    VP.position_nbr as Vacant_Position
FROM VacantPositions VP
WHERE VP.position_nbr = (SELECT position_nbr
FROM [dbo].[UKG_EMPLOYEE_DATA]
WHERE emplid = @emplid);

PRINT '=== STEP 2: Check if position has terminated employees (second update) ===';

-- Check the second update logic
SELECT
    'Does position have terminated reports?' as Question,
    CASE WHEN EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA] E2
        INNER JOIN (
            SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
        ) TE ON E2.position_nbr = TE.reports_to
    WHERE E2.emplid = @emplid
    ) THEN 'YES - Second update sets Manager Flag back to T'
      ELSE 'NO - No terminated reports found'
    END as Answer;

PRINT '=== STEP 3: Detailed analysis ===';

-- Show the terminated employees causing the issue
SELECT
    'Terminated employees reporting to this position:' as Analysis,
    TE.emplid as Terminated_Emplid,
    TE.[First Name] + ' ' + TE.[Last Name] as Terminated_Employee,
    TE.reports_to as Reports_To_Position,
    TE.[termination_dt],
    'This causes Manager Flag to be reset to T in the second update' as Explanation
FROM [dbo].[UKG_EMPLOYEE_DATA] E
    INNER JOIN [dbo].[UKG_EMPLOYEE_DATA] TE ON E.position_nbr = TE.reports_to
WHERE E.emplid = @emplid
    AND TE.[hr_status] = 'I'
    AND TE.emplid != @emplid;

PRINT '=== CONCLUSION ===';

SELECT
    'Why Manager Flag is T:' as Conclusion,
    CASE
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE reports_to = (SELECT position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE emplid = @emplid)
        AND hr_status = 'I' AND emplid != @emplid
        ) THEN 'SP BUG: Position has terminated reports, so second update overrides first update and sets Manager Flag back to T'
        WHEN EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA]
    WHERE reports_to = (SELECT position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE emplid = @emplid)
        AND hr_status = 'A' AND emplid != @emplid
        ) THEN 'Position has active reports - Manager Flag should be T'
        ELSE 'Position has no reports - Manager Flag should be F (but terminated reports prevent this)'
    END as Explanation;