USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]    Script Date: 2/11/2026 7:16:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
    Stored Procedure: [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
    -- 10/08/2025 Jim Shih: Created
    -- 12/03/2025 Jim Shih: Fixed match logic for proper incremental tracking
    -- 12/11/2025 Jim Shih: Enhanced Step 3 deletion logic to prevent duplicate records with same hash_value
    
    Description:
    This stored procedure incrementally inserts records from [dbo].[UKG_EMPLOYEE_DATA] into [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].
    - For each record, a hash value is calculated using HASHBYTES('md5', ...) on key columns to detect changes.
    - Uses three-way logic for comprehensive change tracking:
      1. INSERT (NOTE='I'): New employees not in history
      2. UPDATE (NOTE='U'): Existing employees with changed data (hash mismatch)
      3. DELETE (NOTE='D'): Employees in history but no longer in current data
    - The current date is recorded as snapshot_date for each inserted record.
    - This enables complete tracking of all employee data changes over time.

    New Logic (12/03/2025):
    - If EMPLID exists in target but NOT in source → Insert deletion record (NOTE='D')
    - If EMPLID matches but hash_value differs → Insert update record (NOTE='U') 
    - If EMPLID from source NOT in target → Insert new record (NOTE='I')

    Enhanced Logic (12/11/2025):
    - Step 3 now prevents inserting duplicate deletion records when hash_value is the same
    - Only inserts deletion record if no prior deletion exists with same EMPLID and hash_value
    - Maintains data integrity by avoiding redundant deletion entries

    Usage:
    EXEC [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
*/

ALTER   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT]
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @recordsInserted INT = 0;
    DECLARE @recordsUpdated INT = 0;
    DECLARE @recordsDeleted INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Step 1: INSERT new records (NOTE='I') - EMPLIDs from source NOT in target history for today
        INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        (
        [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG],
        [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status],
        [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name],
        [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email],
        [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date],
        [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type],
        [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly],
        [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name],
        [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity],
        [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group],
        [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9],
        [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3],
        [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date],
        [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6],
        [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2],
        [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13],
        [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19],
        [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25],
        [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups],
        [termination_dt], [action], [action_dt], [hash_value], [NOTE], [snapshot_date]
        )
    SELECT
        src.[DEPTID], src.[VC_CODE], src.[FDM_COMBO_CD], src.[COMBOCODE], src.[REPORTS_TO], src.[MANAGER_EMPLID], src.[NON_UKG_MANAGER_FLAG],
        src.[position_nbr], src.[EMPLID], src.[EMPL_RCD], src.[jobcode], src.[POSITION_DESCR], src.[hr_status], src.[FTE_SUM], src.[fte], src.[empl_Status],
        src.[JobGroup], src.[FundGroup], src.[Person Number], src.[First Name], src.[Last Name], src.[Middle Initial/Name], src.[Short Name],
        src.[Badge Number], src.[Hire Date], src.[Birth Date], src.[Seniority Date], src.[Manager Flag], src.[Phone 1], src.[Phone 2], src.[Email],
        src.[Address], src.[City], src.[State], src.[Postal Code], src.[Country], src.[Time Zone], src.[Employment Status], src.[Employment Status Effective Date],
        src.[Reports to Manager], src.[Union Code], src.[Employee Type], src.[Employee Classification], src.[Pay Frequency], src.[Worker Type],
        src.[FTE %], src.[FTE Standard Hours], src.[FTE Full Time Hours], src.[Standard Hours - Daily], src.[Standard Hours - Weekly],
        src.[Standard Hours - Pay Period], src.[Base Wage Rate], src.[Base Wage Rate Effective Date], src.[User Account Name],
        src.[User Account Status], src.[User Password], src.[Home Business Structure Level 1 - Organization], src.[Home Business Structure Level 2 - Entity],
        src.[Home Business Structure Level 3 - Service Line], src.[Home Business Structure Level 4 - Financial Unit], src.[Home Business Structure Level 5 - Fund Group],
        src.[Home Business Structure Level 6], src.[Home Business Structure Level 7], src.[Home Business Structure Level 8], src.[Home Business Structure Level 9],
        src.[Home/Primary Job], src.[Home Labor Category Level 1], src.[Home Labor Category Level 2], src.[Home Labor Category Level 3],
        src.[Home Labor Category Level 4], src.[Home Labor Category Level 5], src.[Home Labor Category Level 6], src.[Home Job and Labor Category Effective Date],
        src.[Custom Field 1], src.[Custom Field 2], src.[Custom Field 3], src.[Custom Field 4], src.[Custom Field 5], src.[Custom Field 6],
        src.[Custom Field 7], src.[Custom Field 8], src.[Custom Field 9], src.[Custom Field 10], src.[Custom Date 1], src.[Custom Date 2],
        src.[Custom Date 3], src.[Custom Date 4], src.[Custom Date 5], src.[Custom Field 11], src.[Custom Field 12], src.[Custom Field 13],
        src.[Custom Field 14], src.[Custom Field 15], src.[Custom Field 16], src.[Custom Field 17], src.[Custom Field 18], src.[Custom Field 19],
        src.[Custom Field 20], src.[Custom Field 21], src.[Custom Field 22], src.[Custom Field 23], src.[Custom Field 24], src.[Custom Field 25],
        src.[Custom Field 26], src.[Custom Field 27], src.[Custom Field 28], src.[Custom Field 29], src.[Custom Field 30], src.[Additional Fields for CRT lookups],
        src.[termination_dt], src.[action], src.[action_dt],
        HASHBYTES('md5', CONCAT(src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt)) AS hash_value,
        'I' AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
    WHERE NOT EXISTS (
            SELECT 1
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
    WHERE hist.EMPLID = src.EMPLID
        );

        SET @recordsInserted = @@ROWCOUNT;

        -- Step 2: INSERT update records (NOTE='U') - EMPLIDs match but hash values differ
        INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        (
        [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG],
        [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status],
        [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name],
        [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email],
        [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date],
        [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type],
        [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly],
        [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name],
        [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity],
        [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group],
        [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9],
        [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3],
        [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date],
        [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6],
        [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2],
        [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13],
        [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19],
        [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25],
        [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups],
        [termination_dt], [action], [action_dt], [hash_value], [NOTE], [snapshot_date]
        )
    SELECT
        src.[DEPTID], src.[VC_CODE], src.[FDM_COMBO_CD], src.[COMBOCODE], src.[REPORTS_TO], src.[MANAGER_EMPLID], src.[NON_UKG_MANAGER_FLAG],
        src.[position_nbr], src.[EMPLID], src.[EMPL_RCD], src.[jobcode], src.[POSITION_DESCR], src.[hr_status], src.[FTE_SUM], src.[fte], src.[empl_Status],
        src.[JobGroup], src.[FundGroup], src.[Person Number], src.[First Name], src.[Last Name], src.[Middle Initial/Name], src.[Short Name],
        src.[Badge Number], src.[Hire Date], src.[Birth Date], src.[Seniority Date], src.[Manager Flag], src.[Phone 1], src.[Phone 2], src.[Email],
        src.[Address], src.[City], src.[State], src.[Postal Code], src.[Country], src.[Time Zone], src.[Employment Status], src.[Employment Status Effective Date],
        src.[Reports to Manager], src.[Union Code], src.[Employee Type], src.[Employee Classification], src.[Pay Frequency], src.[Worker Type],
        src.[FTE %], src.[FTE Standard Hours], src.[FTE Full Time Hours], src.[Standard Hours - Daily], src.[Standard Hours - Weekly],
        src.[Standard Hours - Pay Period], src.[Base Wage Rate], src.[Base Wage Rate Effective Date], src.[User Account Name],
        src.[User Account Status], src.[User Password], src.[Home Business Structure Level 1 - Organization], src.[Home Business Structure Level 2 - Entity],
        src.[Home Business Structure Level 3 - Service Line], src.[Home Business Structure Level 4 - Financial Unit], src.[Home Business Structure Level 5 - Fund Group],
        src.[Home Business Structure Level 6], src.[Home Business Structure Level 7], src.[Home Business Structure Level 8], src.[Home Business Structure Level 9],
        src.[Home/Primary Job], src.[Home Labor Category Level 1], src.[Home Labor Category Level 2], src.[Home Labor Category Level 3],
        src.[Home Labor Category Level 4], src.[Home Labor Category Level 5], src.[Home Labor Category Level 6], src.[Home Job and Labor Category Effective Date],
        src.[Custom Field 1], src.[Custom Field 2], src.[Custom Field 3], src.[Custom Field 4], src.[Custom Field 5], src.[Custom Field 6],
        src.[Custom Field 7], src.[Custom Field 8], src.[Custom Field 9], src.[Custom Field 10], src.[Custom Date 1], src.[Custom Date 2],
        src.[Custom Date 3], src.[Custom Date 4], src.[Custom Date 5], src.[Custom Field 11], src.[Custom Field 12], src.[Custom Field 13],
        src.[Custom Field 14], src.[Custom Field 15], src.[Custom Field 16], src.[Custom Field 17], src.[Custom Field 18], src.[Custom Field 19],
        src.[Custom Field 20], src.[Custom Field 21], src.[Custom Field 22], src.[Custom Field 23], src.[Custom Field 24], src.[Custom Field 25],
        src.[Custom Field 26], src.[Custom Field 27], src.[Custom Field 28], src.[Custom Field 29], src.[Custom Field 30], src.[Additional Fields for CRT lookups],
        src.[termination_dt], src.[action], src.[action_dt],
        HASHBYTES('md5', CONCAT(src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt)) AS hash_value,
        'U' AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA] src
        INNER JOIN (
            SELECT EMPLID, MAX(snapshot_date) AS latest_date
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        GROUP BY EMPLID
        ) latest ON src.EMPLID = latest.EMPLID
        INNER JOIN [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
        ON src.EMPLID = hist.EMPLID AND hist.snapshot_date = latest.latest_date
    WHERE hist.hash_value != HASHBYTES('md5', CONCAT(src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt))
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] check_today
        WHERE check_today.EMPLID = src.EMPLID
            AND check_today.snapshot_date = @today
            AND check_today.NOTE IN ('I', 'U')
        );

        SET @recordsUpdated = @@ROWCOUNT;

        -- Step 3: INSERT deletion records (NOTE='D') - EMPLIDs in target but NOT in source
        INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        (
        [DEPTID], [VC_CODE], [FDM_COMBO_CD], [COMBOCODE], [REPORTS_TO], [MANAGER_EMPLID], [NON_UKG_MANAGER_FLAG],
        [position_nbr], [EMPLID], [EMPL_RCD], [jobcode], [POSITION_DESCR], [hr_status], [FTE_SUM], [fte], [empl_Status],
        [JobGroup], [FundGroup], [Person Number], [First Name], [Last Name], [Middle Initial/Name], [Short Name],
        [Badge Number], [Hire Date], [Birth Date], [Seniority Date], [Manager Flag], [Phone 1], [Phone 2], [Email],
        [Address], [City], [State], [Postal Code], [Country], [Time Zone], [Employment Status], [Employment Status Effective Date],
        [Reports to Manager], [Union Code], [Employee Type], [Employee Classification], [Pay Frequency], [Worker Type],
        [FTE %], [FTE Standard Hours], [FTE Full Time Hours], [Standard Hours - Daily], [Standard Hours - Weekly],
        [Standard Hours - Pay Period], [Base Wage Rate], [Base Wage Rate Effective Date], [User Account Name],
        [User Account Status], [User Password], [Home Business Structure Level 1 - Organization], [Home Business Structure Level 2 - Entity],
        [Home Business Structure Level 3 - Service Line], [Home Business Structure Level 4 - Financial Unit], [Home Business Structure Level 5 - Fund Group],
        [Home Business Structure Level 6], [Home Business Structure Level 7], [Home Business Structure Level 8], [Home Business Structure Level 9],
        [Home/Primary Job], [Home Labor Category Level 1], [Home Labor Category Level 2], [Home Labor Category Level 3],
        [Home Labor Category Level 4], [Home Labor Category Level 5], [Home Labor Category Level 6], [Home Job and Labor Category Effective Date],
        [Custom Field 1], [Custom Field 2], [Custom Field 3], [Custom Field 4], [Custom Field 5], [Custom Field 6],
        [Custom Field 7], [Custom Field 8], [Custom Field 9], [Custom Field 10], [Custom Date 1], [Custom Date 2],
        [Custom Date 3], [Custom Date 4], [Custom Date 5], [Custom Field 11], [Custom Field 12], [Custom Field 13],
        [Custom Field 14], [Custom Field 15], [Custom Field 16], [Custom Field 17], [Custom Field 18], [Custom Field 19],
        [Custom Field 20], [Custom Field 21], [Custom Field 22], [Custom Field 23], [Custom Field 24], [Custom Field 25],
        [Custom Field 26], [Custom Field 27], [Custom Field 28], [Custom Field 29], [Custom Field 30], [Additional Fields for CRT lookups],
        [termination_dt], [action], [action_dt], [hash_value], [NOTE], [snapshot_date]
        )
    SELECT
        hist.[DEPTID], hist.[VC_CODE], hist.[FDM_COMBO_CD], hist.[COMBOCODE], hist.[REPORTS_TO], hist.[MANAGER_EMPLID], hist.[NON_UKG_MANAGER_FLAG],
        hist.[position_nbr], hist.[EMPLID], hist.[EMPL_RCD], hist.[jobcode], hist.[POSITION_DESCR], hist.[hr_status], hist.[FTE_SUM], hist.[fte], hist.[empl_Status],
        hist.[JobGroup], hist.[FundGroup], hist.[Person Number], hist.[First Name], hist.[Last Name], hist.[Middle Initial/Name], hist.[Short Name],
        hist.[Badge Number], hist.[Hire Date], hist.[Birth Date], hist.[Seniority Date], hist.[Manager Flag], hist.[Phone 1], hist.[Phone 2], hist.[Email],
        hist.[Address], hist.[City], hist.[State], hist.[Postal Code], hist.[Country], hist.[Time Zone], hist.[Employment Status], hist.[Employment Status Effective Date],
        hist.[Reports to Manager], hist.[Union Code], hist.[Employee Type], hist.[Employee Classification], hist.[Pay Frequency], hist.[Worker Type],
        hist.[FTE %], hist.[FTE Standard Hours], hist.[FTE Full Time Hours], hist.[Standard Hours - Daily], hist.[Standard Hours - Weekly],
        hist.[Standard Hours - Pay Period], hist.[Base Wage Rate], hist.[Base Wage Rate Effective Date], hist.[User Account Name],
        hist.[User Account Status], hist.[User Password], hist.[Home Business Structure Level 1 - Organization], hist.[Home Business Structure Level 2 - Entity],
        hist.[Home Business Structure Level 3 - Service Line], hist.[Home Business Structure Level 4 - Financial Unit], hist.[Home Business Structure Level 5 - Fund Group],
        hist.[Home Business Structure Level 6], hist.[Home Business Structure Level 7], hist.[Home Business Structure Level 8], hist.[Home Business Structure Level 9],
        hist.[Home/Primary Job], hist.[Home Labor Category Level 1], hist.[Home Labor Category Level 2], hist.[Home Labor Category Level 3],
        hist.[Home Labor Category Level 4], hist.[Home Labor Category Level 5], hist.[Home Labor Category Level 6], hist.[Home Job and Labor Category Effective Date],
        hist.[Custom Field 1], hist.[Custom Field 2], hist.[Custom Field 3], hist.[Custom Field 4], hist.[Custom Field 5], hist.[Custom Field 6],
        hist.[Custom Field 7], hist.[Custom Field 8], hist.[Custom Field 9], hist.[Custom Field 10], hist.[Custom Date 1], hist.[Custom Date 2],
        hist.[Custom Date 3], hist.[Custom Date 4], hist.[Custom Date 5], hist.[Custom Field 11], hist.[Custom Field 12], hist.[Custom Field 13],
        hist.[Custom Field 14], hist.[Custom Field 15], hist.[Custom Field 16], hist.[Custom Field 17], hist.[Custom Field 18], hist.[Custom Field 19],
        hist.[Custom Field 20], hist.[Custom Field 21], hist.[Custom Field 22], hist.[Custom Field 23], hist.[Custom Field 24], hist.[Custom Field 25],
        hist.[Custom Field 26], hist.[Custom Field 27], hist.[Custom Field 28], hist.[Custom Field 29], hist.[Custom Field 30], hist.[Additional Fields for CRT lookups],
        hist.[termination_dt], hist.[action], hist.[action_dt], hist.[hash_value],
        'D' AS NOTE,
        @today AS snapshot_date
    FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] hist
        INNER JOIN (
            SELECT EMPLID, MAX(snapshot_date) AS latest_date
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        GROUP BY EMPLID
        ) latest ON hist.EMPLID = latest.EMPLID AND hist.snapshot_date = latest.latest_date
    WHERE NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA] src
        WHERE src.EMPLID = hist.EMPLID
        )
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] check_today
        WHERE check_today.EMPLID = hist.EMPLID
            AND check_today.snapshot_date = @today
            AND check_today.NOTE = 'D'
        )
        AND NOT EXISTS (
            SELECT 1
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] check_same_hash
        WHERE check_same_hash.EMPLID = hist.EMPLID
            AND check_same_hash.hash_value = hist.hash_value
            AND check_same_hash.NOTE = 'D'
        );

        SET @recordsDeleted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- Return summary
        SELECT
        'Daily Incremental History Update Completed' AS Status,
        @recordsInserted AS Records_Inserted_I,
        @recordsUpdated AS Records_Updated_U,
        @recordsDeleted AS Records_Deleted_D,
        (@recordsInserted + @recordsUpdated + @recordsDeleted) AS Total_Records_Processed,
        @today AS Snapshot_Date;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


