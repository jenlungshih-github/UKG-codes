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
* EXEC [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
* -- 09/15/2025 Jim Shih: Created procedure based on 46.sql logic
* --                      Uses CTE mPOSN_Manager_Flag_To_Update to identify vacant manager positions
* --                      Updates Manager Flag to 'F' for employees whose position_nbr matches vacant manager positions
* --                      Vacant manager positions = positions where Manager Flag='T' but no active employees report to them
******************************************/

CREATE or Alter PROCEDURE [stage].[SP_UKG_EMPL_Update_Manager_Flag-Step4]
AS
BEGIN
    SET NOCOUNT ON;

    -- Create temp table to store vacant manager positions
    DROP TABLE IF EXISTS #mPOSN_Manager_Flag_To_Update;
    CREATE TABLE #mPOSN_Manager_Flag_To_Update
    (
        position_nbr VARCHAR(20) PRIMARY KEY
    );

    -- Insert vacant manager positions into temp table
    -- CTE based on 46.sql logic: Find vacant manager positions (flagged as managers but no active reports)
    WITH
        TERMINATED_empl
        AS
        (
            SELECT emplid, reports_to
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            WHERE [hr_status]='I'
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
    INSERT INTO #mPOSN_Manager_Flag_To_Update
        (position_nbr)
    SELECT position_nbr
    FROM VacantPositions;

    -- Now create mPOSN_with_iEMPL after temp table is populated
    WITH
        mPOSN_with_iEMPL
        AS
        (
            SELECT DISTINCT VMP.[position_nbr]
            FROM #mPOSN_Manager_Flag_To_Update VMP
                INNER JOIN (
            SELECT emplid, reports_to
                FROM [dbo].[UKG_EMPLOYEE_DATA]
                WHERE [hr_status]='I'
        ) TE ON TE.reports_to = VMP.[position_nbr]
        )
    -- Could use mPOSN_with_iEMPL for additional logic here if needed
    SELECT *
    INTO #Temp_mPOSN_with_iEMPL
    FROM mPOSN_with_iEMPL;

    -- Update Manager Flag to 'F' for employees in vacant manager positions
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show summary of changes
    SELECT
        'Employees updated to Manager Flag = ''F''' as Description,
        COUNT(*) as Count
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr;

    -- Show the vacant positions that were updated
    PRINT 'Vacant manager positions updated:';
    SELECT DISTINCT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag]
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #mPOSN_Manager_Flag_To_Update VMP
        ON E.position_nbr = VMP.position_nbr
    ORDER BY E.position_nbr;

    -- Show positions that have terminated employees reporting to them
    PRINT 'Vacant positions with terminated employees:';
    SELECT DISTINCT
        VMP.position_nbr,
        COUNT(TE.emplid) as Terminated_Employee_Count
    FROM #mPOSN_Manager_Flag_To_Update VMP
        INNER JOIN (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
    ) TE ON TE.reports_to = VMP.position_nbr
    GROUP BY VMP.position_nbr
    ORDER BY VMP.position_nbr;

    -- Update Manager Flag back to 'T' for positions that have terminated employees reporting to them
    -- These positions may still be considered manager positions due to historical reporting relationships
    UPDATE E
    SET [Manager Flag] = 'T'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #Temp_mPOSN_with_iEMPL MWIE
        ON E.position_nbr = MWIE.position_nbr;

    -- Show summary of the second update
    PRINT 'Positions updated back to Manager Flag = ''T'' (have terminated employees):';
    SELECT
        E.position_nbr,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag],
        COUNT(TE.emplid) as Terminated_Reports_Count
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN #Temp_mPOSN_with_iEMPL MWIE
        ON E.position_nbr = MWIE.position_nbr
        LEFT JOIN (
        SELECT emplid, reports_to
        FROM [dbo].[UKG_EMPLOYEE_DATA]
        WHERE [hr_status]='I'
    ) TE ON TE.reports_to = E.position_nbr
    GROUP BY E.position_nbr, E.emplid, E.[First Name], E.[Last Name], E.[Manager Flag]
    ORDER BY E.position_nbr;

    -- Clean up temp tables
    DROP TABLE IF EXISTS #mPOSN_Manager_Flag_To_Update;
    DROP TABLE IF EXISTS #Temp_mPOSN_with_iEMPL;

END;

GO
