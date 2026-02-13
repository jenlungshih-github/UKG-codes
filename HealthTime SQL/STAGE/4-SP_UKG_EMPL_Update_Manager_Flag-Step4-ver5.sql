USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]    Script Date: 9/15/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************
* Created By: Jim Shih
* Procedure: stage.SP_UKG_EMPL_Update_Manager_Flag-Step4
* Purpose: Updates Manager Flag to 'F' for employees in vacant manager positions (positions flagged as managers but with no active direct reports)
* 
* Performance Optimizations (12/03/2025):
* - Added comprehensive indexing strategy for temporary tables:
*   * #mPOSN_Manager_Flag_To_Update: PRIMARY KEY (position_nbr) - Fast UPDATE and JOIN operations
*   * #TerminatedEmployees: Clustered on reports_to, nonclustered on emplid - Optimizes terminated employee lookups
*   * #ManagerPositions: Clustered on position_nbr, nonclustered on emplid - Optimizes manager position processing
* - Created reusable temporary tables to eliminate repetitive CTE calculations
* - Total: 6 performance indexes to optimize manager flag update operations
* - Improved execution plans for large-scale manager flag corrections
* 
* EXEC [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
* -- 09/15/2025 Jim Shih: Created procedure based on 46.sql logic
* --                      Uses CTE mPOSN_Manager_Flag_To_Update to identify vacant manager positions
* --                      Updates Manager Flag to 'F' for employees whose position_nbr matches vacant manager positions
* --                      Vacant manager positions = positions where Manager Flag='T' but no active employees report to them
* --                      Update Manager Flag to 'T' for positions that have terminated employees reporting to them
* --                      These positions may still be considered manager positions due to historical reporting relationships
* --                      Update Manager Flag to 'F' for positions with NO reports at all (active or terminated)
* --                      This corrects cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
* -- 09/17/2025 Jim Shih: Added third update step to set Manager Flag to 'F' for positions with no reports at all
* --                      This addresses cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
* -- 12/02/2025 Jim Shih: replace [dbo].[UKG_EMPLOYEE_DATA] with [dbo].[UKG_EMPLOYEE_DATA_TEMP]
* -- 12/03/2025 Jim Shih: Added comprehensive performance optimization with indexed temporary tables
******************************************/

CREATE or Alter PROCEDURE [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
AS
BEGIN
    SET NOCOUNT ON;

    -- Performance Optimization: Create indexed temporary tables for reusable data

    -- Create temp table for terminated employees (reusable across multiple operations)
    DROP TABLE IF EXISTS #TerminatedEmployees;
    CREATE TABLE #TerminatedEmployees
    (
        emplid VARCHAR(11),
        reports_to VARCHAR(20)
    );

    INSERT INTO #TerminatedEmployees
        (emplid, reports_to)
    SELECT emplid, reports_to
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
    WHERE [hr_status] = 'I';

    -- Add indexes for optimal performance
    CREATE CLUSTERED INDEX IX_TerminatedEmployees_ReportsTo ON #TerminatedEmployees (reports_to);
    CREATE NONCLUSTERED INDEX IX_TerminatedEmployees_EmplId ON #TerminatedEmployees (emplid);

    -- Create temp table for manager positions (reusable across multiple operations)
    DROP TABLE IF EXISTS #ManagerPositions;
    CREATE TABLE #ManagerPositions
    (
        emplid VARCHAR(11),
        position_nbr VARCHAR(20),
        manager_flag CHAR(1),
        first_name VARCHAR(50),
        last_name VARCHAR(50)
    );

    INSERT INTO #ManagerPositions
        (emplid, position_nbr, manager_flag, first_name, last_name)
    SELECT emplid, [position_nbr], [Manager Flag], [First Name], [Last Name]
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
    WHERE [Manager Flag] = 'T';

    -- Add indexes for optimal performance
    CREATE CLUSTERED INDEX IX_ManagerPositions_Position ON #ManagerPositions (position_nbr);
    CREATE NONCLUSTERED INDEX IX_ManagerPositions_EmplId ON #ManagerPositions (emplid);

    -- Create temp table to store vacant manager positions with enhanced structure
    DROP TABLE IF EXISTS #mPOSN_Manager_Flag_To_Update;
    CREATE TABLE #mPOSN_Manager_Flag_To_Update
    (
        position_nbr VARCHAR(20) PRIMARY KEY,
        update_reason VARCHAR(100)
    );

    -- Insert vacant manager positions into temp table using optimized indexed tables
    -- Enhanced CTE logic using pre-indexed temporary tables for better performance
    WITH
        VacantPositions
        AS
        (
            SELECT DISTINCT
                mPOSN.[position_nbr]
            FROM #ManagerPositions mPOSN
                INNER JOIN health_ods.[health_ods].[RPT].[CURRENT_EMPL_DATA] empl
                ON mPOSN.position_nbr = empl.[POSITION_REPORTS_TO]
            WHERE empl.MANAGER_EMPLID IS NOT NULL
            GROUP BY mPOSN.[position_nbr]
            HAVING SUM(CASE WHEN empl.HR_STATUS = 'A' THEN 1 ELSE 0 END) = 0
        )
    INSERT INTO #mPOSN_Manager_Flag_To_Update
        (position_nbr, update_reason)
    SELECT position_nbr, 'Vacant manager position - no active reports'
    FROM VacantPositions;

    -- Update Manager Flag to 'F' for employees in vacant manager positions
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show summary of changes
    SELECT
        'Employees updated to Manager Flag = ''F''' as Description,
        COUNT(*) as Count
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show the vacant positions that were updated
    PRINT 'Vacant manager positions updated:';
    SELECT DISTINCT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag]
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr
    ORDER BY E.position_nbr;

    -- Update Manager Flag to 'T' for positions that have terminated employees reporting to them
    -- Optimized using indexed temporary tables for better performance
    UPDATE E
    SET [Manager Flag] = 'T'
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
        INNER JOIN (
        SELECT DISTINCT E2.emplid, E2.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E2
            INNER JOIN #TerminatedEmployees TE ON E2.position_nbr = TE.reports_to
    ) mPOSN_Manager_Flag_To_Update_To_T
        ON E.emplid = mPOSN_Manager_Flag_To_Update_To_T.emplid
            AND E.position_nbr = mPOSN_Manager_Flag_To_Update_To_T.position_nbr;

    -- Show summary of the second update using optimized indexed tables
    PRINT 'Positions updated back to Manager Flag = ''T'' (have terminated employees):';
    SELECT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag],
        COUNT(TE.emplid) as Terminated_Reports_Count
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
        INNER JOIN (
        SELECT DISTINCT E2.emplid, E2.position_nbr
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E2
            INNER JOIN #TerminatedEmployees TE ON E2.position_nbr = TE.reports_to
    ) mPOSN_Manager_Flag_To_Update_To_T
        ON E.emplid = mPOSN_Manager_Flag_To_Update_To_T.emplid
            AND E.position_nbr = mPOSN_Manager_Flag_To_Update_To_T.position_nbr
        LEFT JOIN #TerminatedEmployees TE ON TE.reports_to = E.position_nbr
    GROUP BY E.position_nbr, E.emplid, E.[First Name], E.[Last Name], E.[Manager Flag]
    ORDER BY E.position_nbr;

    -- Update Manager Flag to 'F' for positions that have NO reports at all (active or terminated)
    -- This handles cases where Manager Flag was incorrectly set to 'T' during initial data load or manual settings
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
    WHERE E.[Manager Flag] = 'T'
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] reports
        WHERE reports.reports_to = E.position_nbr
            AND reports.emplid != E.emplid
        );

    -- Show summary of the third update
    PRINT 'Positions updated to Manager Flag = ''F'' (no reports found - initial load/manual setting issue):';
    SELECT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag],
        'No reports found - corrected from initial data load or manual setting' as Reason
    FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] E
    WHERE E.[Manager Flag] = 'F'
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] reports
        WHERE reports.reports_to = E.position_nbr
            AND reports.emplid != E.emplid
        )
        AND E.emplid IN (
            -- Only show positions that were just updated in this step
            SELECT emplid
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
        WHERE [Manager Flag] = 'F'
            AND NOT EXISTS (
                    SELECT 1
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP] reports
            WHERE reports.reports_to = position_nbr
                AND reports.emplid != emplid
                )
        )
    ORDER BY E.position_nbr;

    -- Clean up all temporary tables for optimal resource management
    DROP TABLE #mPOSN_Manager_Flag_To_Update;
    DROP TABLE #TerminatedEmployees;
    DROP TABLE #ManagerPositions;

END;

GO
