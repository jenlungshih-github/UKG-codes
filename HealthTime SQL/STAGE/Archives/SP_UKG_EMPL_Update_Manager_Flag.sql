USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPL_Update_Manager_Flag]    Script Date: 9/15/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************
* Created By: Jim Shih
* Procedure: stage.SP_UKG_EMPL_Update_Manager_Flag
* Purpose: Updates Manager Flag to 'F' for employees in vacant manager positions (positions flagged as managers but with no active direct reports)
* EXEC [stage].[SP_UKG_EMPL_Update_Manager_Flag]
* -- 09/15/2025 Jim Shih: Created procedure based on 46.sql logic
* --                      Uses CTE mPOSN_Manager_Flag_To_Update to identify vacant manager positions
* --                      Updates Manager Flag to 'F' for employees whose position_nbr matches vacant manager positions
* --                      Vacant manager positions = positions where Manager Flag='T' but no active employees report to them
******************************************/

CREATE PROCEDURE [stage].[SP_UKG_EMPL_Update_Manager_Flag]
AS
BEGIN
    SET NOCOUNT ON;

    -- CTE based on 46.sql logic: Find vacant manager positions (flagged as managers but no active reports)
    WITH
        mPOSN_Manager_Flag_To_Update
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
    -- Update Manager Flag to 'F' for employees in vacant manager positions
    UPDATE E
    SET [Manager Flag] = 'F'
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN mPOSN_Manager_Flag_To_Update VMP
        ON E.reports_to = VMP.position_nbr;

    PRINT 'Manager Flag updated to ''F'' for employees in vacant manager positions';

    -- Show summary of changes
    SELECT
        'Employees updated to Manager Flag = ''F''' as Description,
        COUNT(*) as Count
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN (
        SELECT DISTINCT mPOSN.[position_nbr]
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
    ) VMP ON E.Reports_To = VMP.position_nbr;

    -- Show the vacant positions that were updated
    PRINT 'Vacant manager positions updated:';
    SELECT DISTINCT
        E.Reports_To,
        E.emplid,
        E.[First Name] + ' ' + E.[Last Name] as Employee_Name,
        E.[Manager Flag]
    FROM [dbo].[UKG_EMPLOYEE_DATA] E
        INNER JOIN (
        SELECT DISTINCT mPOSN.[position_nbr]
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
    ) VMP ON E.Reports_To = VMP.position_nbr
    ORDER BY E.Reports_To;

END;

GO
