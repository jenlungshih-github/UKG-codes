USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]    Script Date: 10/8/2025 1:42:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
    Stored Procedure: [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
    -- 10/08/2025 Jim Shih: Created

    Description:
    This stored procedure incrementally inserts records from [dbo].[UKG_EMPLOYEE_DATA] into [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].
    - For each record, a hash value is calculated using HASHBYTES('md5', ...) on key columns to detect changes.
    - Only records with a new hash value (i.e., not already present in the history table) are inserted.
    - The current date is recorded as snapshot_date for each inserted record.
    - This enables tracking of historical changes to employee data over time.
    - Uses MERGE to insert missing (deleted) records from the previous snapshots, avoiding duplicates:

    Usage:
    EXEC [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
*/

CREATE or ALTER   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    SELECT *,
        HASHBYTES('md5', CONCAT(
            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt
        )) AS hash_value,
        'I' AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE NOT EXISTS (
        SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
    WHERE hist.EMPLID = src.EMPLID
        AND hist.hash_value = HASHBYTES('md5', CONCAT(
                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt
            ))
    );

    -- Use MERGE to avoid duplicate records for deletions
    MERGE INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] AS target
    USING (
        SELECT
        [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG], [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status], [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name], [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email], [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date], [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type], [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly], [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name], [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity], [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group], [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9], [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3], [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date], [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6], [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2], [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13], [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19], [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25], [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups], [termination_dt], [action], [action_dt], [hash_value],
        'D' AS [NOTE],
        @today AS [snapshot_date]
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
    WHERE NOT EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE src.[EMPLID] = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].[EMPLID]
        )
    ) AS source
    ON target.[EMPLID] = source.[EMPLID]
        --AND target.[snapshot_date] = source.[snapshot_date] 
        AND target.[hash_value] = source.[hash_value]
        and target.[NOTE] = source.[NOTE]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG], [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status], [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name], [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email], [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date], [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type], [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly], [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name], [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity], [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group], [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9], [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3], [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date], [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6], [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2], [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13], [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19], [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25], [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups], [termination_dt], [action], [action_dt], [hash_value], [NOTE], [snapshot_date]
        )
        VALUES (
            source.[DEPTID], source.[VC_CODE], source.[FDM_COMBO_CD], source.[COMBOCODE], source.[REPORTS_TO], source.[MANAGER_EMPLID], source.[NON_UKG_MANAGER_FLAG], source.[position_nbr], source.[EMPLID], source.[EMPL_RCD], source.[jobcode], source.[POSITION_DESCR], source.[hr_status], source.[FTE_SUM], source.[fte], source.[empl_Status], source.[JobGroup], source.[FundGroup], source.[Person Number], source.[First Name], source.[Last Name], source.[Middle Initial/Name], source.[Short Name], source.[Badge Number], source.[Hire Date], source.[Birth Date], source.[Seniority Date], source.[Manager Flag], source.[Phone 1], source.[Phone 2], source.[Email], source.[Address], source.[City], source.[State], source.[Postal Code], source.[Country], source.[Time Zone], source.[Employment Status], source.[Employment Status Effective Date], source.[Reports to Manager], source.[Union Code], source.[Employee Type], source.[Employee Classification], source.[Pay Frequency], source.[Worker Type], source.[FTE %], source.[FTE Standard Hours], source.[FTE Full Time Hours], source.[Standard Hours - Daily], source.[Standard Hours - Weekly], source.[Standard Hours - Pay Period], source.[Base Wage Rate], source.[Base Wage Rate Effective Date], source.[User Account Name], source.[User Account Status], source.[User Password], source.[Home Business Structure Level 1 - Organization], source.[Home Business Structure Level 2 - Entity], source.[Home Business Structure Level 3 - Service Line], source.[Home Business Structure Level 4 - Financial Unit], source.[Home Business Structure Level 5 - Fund Group], source.[Home Business Structure Level 6], source.[Home Business Structure Level 7], source.[Home Business Structure Level 8], source.[Home Business Structure Level 9], source.[Home/Primary Job], source.[Home Labor Category Level 1], source.[Home Labor Category Level 2], source.[Home Labor Category Level 3], source.[Home Labor Category Level 4], source.[Home Labor Category Level 5], source.[Home Labor Category Level 6], source.[Home Job and Labor Category Effective Date], source.[Custom Field 1], source.[Custom Field 2], source.[Custom Field 3], source.[Custom Field 4], source.[Custom Field 5], source.[Custom Field 6], source.[Custom Field 7], source.[Custom Field 8], source.[Custom Field 9], source.[Custom Field 10], source.[Custom Date 1], source.[Custom Date 2], source.[Custom Date 3], source.[Custom Date 4], source.[Custom Date 5], source.[Custom Field 11], source.[Custom Field 12], source.[Custom Field 13], source.[Custom Field 14], source.[Custom Field 15], source.[Custom Field 16], source.[Custom Field 17], source.[Custom Field 18], source.[Custom Field 19], source.[Custom Field 20], source.[Custom Field 21], source.[Custom Field 22], source.[Custom Field 23], source.[Custom Field 24], source.[Custom Field 25], source.[Custom Field 26], source.[Custom Field 27], source.[Custom Field 28], source.[Custom Field 29], source.[Custom Field 30], source.[Additional Fields for CRT lookups], source.[termination_dt], source.[action], source.[action_dt], source.[hash_value], source.[NOTE], source.[snapshot_date]
        );
END
GO


