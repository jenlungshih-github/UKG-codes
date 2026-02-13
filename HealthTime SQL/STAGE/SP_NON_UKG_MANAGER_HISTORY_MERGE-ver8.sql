USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_NON_UKG_MANAGER_HISTORY_MERGE]    Script Date: 12/03/2025 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************
* Stored Procedure: [stage].[SP_NON_UKG_MANAGER_HISTORY_MERGE]
* Created By: GitHub Copilot
* Created Date: 12/03/2025
* Purpose: Merge Non-UKG Manager data from UKG_EMPLOYEE_DATA_TEMP into NON_UKG_MANAGER_HISTORY table
*          using composite key matching on [Person Number] AND [Manager Flag]
* 
* Business Logic:
* - Sources data from UKG_EMPLOYEE_DATA_TEMP where NON_UKG_MANAGER_FLAG='T' OR Manager Flag='T' with BYA exclusions
* - Uses MERGE operation with composite key: [Person Number] AND [Manager Flag]
* - Only inserts new records when no match exists (WHEN NOT MATCHED BY TARGET)
* - Preserves historical snapshots with snapshot_date timestamp
* - Includes comprehensive error handling and transaction management
* 
* Composite Key Logic:
* - [Person Number]: Unique employee identifier from source system
* - [Manager Flag]: Manager status flag ('T'/'F') to track manager role changes over time
* - This allows tracking of manager flag changes for the same person as separate historical records
* 
* Data Sources:
* - [dbo].[UKG_EMPLOYEE_DATA_TEMP]: Primary employee data source
* - STAGE.CTE_EXCLUDE_BYA: Exclusion list for BYA (specific business rule)
* 
* Target Table:
* - [dbo].[NON_UKG_MANAGER_HISTORY]: Historical tracking table for non-UKG managers
* 
* Performance Considerations:
* - Uses MERGE for optimal performance with large datasets
* - Composite key indexing on target table recommended for performance
* - Transaction-wrapped for data consistency
* 
* Usage: EXEC [stage].[SP_NON_UKG_MANAGER_HISTORY_MERGE]
* 
* Dependencies:
* - [dbo].[UKG_EMPLOYEE_DATA_TEMP] table must exist and be populated
* - STAGE.CTE_EXCLUDE_BYA view/table must exist
* - [dbo].[NON_UKG_MANAGER_HISTORY] target table must exist
* 
* Expected Output:
* - Summary of records inserted
* - Error handling with detailed messaging
* - Transaction rollback on failure
* 
* Created: 12/03/2025 - Initial creation with MERGE logic and composite key matching
* Updated: 12/16/2025 - Added Custom Field 9 update logic to set 'T' for all manager records
*                      - Updates [Custom Field 9] = 'T' WHERE [Manager Flag] = 'T'
*                      - Applied after MERGE operation and before transaction commit
*                      - Added hash_value calculation and column to INSERT operation
*                      - Fixed NULL constraint error for hash_value column
* Updated: 01/22/2026 - Added deletion marking when source no longer contains composite key
*                      - Restrict deletion marking to active records (NOTE IS NULL)
*                      - MERGE clause updated: WHEN NOT MATCHED BY SOURCE AND TARGET.[NOTE] IS NULL THEN UPDATE SET [NOTE]='D', [snapshot_date]=GETDATE()
* Updated: 01/28/2026 - Added logic to mark rows with T.[NOTE] = 'P' when source EMPLID matches target EMPLID but NON_UKG_MANAGER_FLAG changes from 'T' to 'F'.
* Updated: 02/03/2026 - mark NOTE='P' when source EMPLID matches target EMPLID and NON_UKG_MANAGER_FLAG changes from 'T' to 'F'; excluded rows where NOTE='D'.
*
* Technical Details:
* - Version: 1.4 (2026-01-28)
* - Added logic to handle cases where the NON_UKG_MANAGER_FLAG changes from 'T' to 'F' for matching EMPLID between source and target.
* - Updates the [NOTE] column to 'P' and sets [Update_DT] to GETDATE() for such rows.
* - Ensures accurate tracking of changes in manager status for historical records.
*
* - Version: 1.3 (2026-01-23)
* - Hashing: HASHBYTES('md5', CONCAT(EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt)) stored in [hash_value]
* - Composite key for insert logic: [Person Number], [Manager Flag]
* - NOTE column semantics: NULL = active, 'D' = deleted, 'I' = inserted, 'P' = pending (used when marking target rows not present in source)
* - Update_DT: [Update_DT] [date] NULL is populated with GETDATE() when inserting or marking deletions/reactivations
* - Deletion-marking behavior: rows missing from source and currently active are updated to set [Employment Status]='T', [Employment Status Effective Date]=FORMAT(GETDATE(), 'yyyy-MM-dd'), [Update_DT]=GETDATE(), [NOTE]='P' and [Manager Flag]='F'
* - Reactivation logic: when a source row matches a target row with NOTE='D' and identical [hash_value], the procedure updates the deleted row's [Update_DT] and inserts a new active history record from SourceData
* - MERGE replacement: MERGE was replaced with explicit INSERT/UPDATE operations to avoid MERGE parsing issues in T-SQL
* - Transactional: Operation is wrapped in a transaction with TRY/CATCH and THROW for error propagation
* - Performance: SourceData CTE reads from [dbo].[UKG_EMPLOYEE_DATA_TEMP]; ensure indexes exist on EMPLID, jobcode, [Person Number]; recommended indexes on target: ([Person Number], [Manager Flag]), [NOTE], [Update_DT], [hash_value]

* - 2026-01-23: Version 1.3 - Changed deletion-marking to set Employment Status and NOTE='P', update [Update_DT], set Manager Flag to 'F'; added header/version update
* - 2026-01-23: Version 1.2 - Added reactivation logic (update [Update_DT] and insert new active row when source matches a deleted target with same hash); replaced MERGE with INSERT/UPDATE; added duplicate-prevention for reactivated inserts
* - 2026-01-22: Added deletion marking to MERGE; limited to active rows; no additional hash history column added
* - 12/16/2025: Added Custom Field 9 update logic and hash_value calculation
******************************************/

CREATE OR ALTER PROCEDURE [stage].[SP_NON_UKG_MANAGER_HISTORY_MERGE]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordsInserted INT = 0;
    DECLARE @RecordsDeleted INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- MERGE operation to insert only new records based on composite key
        WITH
        SourceData
        AS
        (
            SELECT [DEPTID]
                  , [VC_CODE]
                  , [FDM_COMBO_CD]
                  , [COMBOCODE]
                  , [REPORTS_TO]
                  , [MANAGER_EMPLID]
                  , [NON_UKG_MANAGER_FLAG]
                  , [position_nbr]
                  , [EMPLID]
                  , [EMPL_RCD]
                  , [jobcode]
                  , [POSITION_DESCR]
                  , [hr_status]
                  , [FTE_SUM]
                  , [fte]
                  , [empl_Status]
                  , [JobGroup]
                  , [FundGroup]
                  , [Person Number]
                  , [First Name]
                  , [Last Name]
                  , [Middle Initial/Name]
                  , [Short Name]
                  , [Badge Number]
                  , [Hire Date]
                  , [Birth Date]
                  , [Seniority Date]
                  , [Manager Flag]
                  , [Phone 1]
                  , [Phone 2]
                  , [Email]
                  , [Address]
                  , [City]
                  , [State]
                  , [Postal Code]
                  , [Country]
                  , [Time Zone]
                  , [Employment Status]
                  , [Employment Status Effective Date]
                  , [Reports to Manager]
                  , [Union Code]
                  , [Employee Type]
                  , [Employee Classification]
                  , [Pay Frequency]
                  , [Worker Type]
                  , [FTE %]
                  , [FTE Standard Hours]
                  , [FTE Full Time Hours]
                  , [Standard Hours - Daily]
                  , [Standard Hours - Weekly]
                  , [Standard Hours - Pay Period]
                  , [Base Wage Rate]
                  , [Base Wage Rate Effective Date]
                  , [User Account Name]
                  , [User Account Status]
                  , [User Password]
                  , [Home Business Structure Level 1 - Organization]
                  , [Home Business Structure Level 2 - Entity]
                  , [Home Business Structure Level 3 - Service Line]
                  , [Home Business Structure Level 4 - Financial Unit]
                  , [Home Business Structure Level 5 - Fund Group]
                  , [Home Business Structure Level 6]
                  , [Home Business Structure Level 7]
                  , [Home Business Structure Level 8]
                  , [Home Business Structure Level 9]
                  , [Home/Primary Job]
                  , [Home Labor Category Level 1]
                  , [Home Labor Category Level 2]
                  , [Home Labor Category Level 3]
                  , [Home Labor Category Level 4]
                  , [Home Labor Category Level 5]
                  , [Home Labor Category Level 6]
                  , [Home Job and Labor Category Effective Date]
                  , [Custom Field 1]
                  , [Custom Field 2]
                  , [Custom Field 3]
                  , [Custom Field 4]
                  , [Custom Field 5]
                  , [Custom Field 6]
                  , [Custom Field 7]
                  , [Custom Field 8]
                  , [Custom Field 9]
                  , [Custom Field 10]
                  , [Custom Date 1]
                  , [Custom Date 2]
                  , [Custom Date 3]
                  , [Custom Date 4]
                  , [Custom Date 5]
                  , [Custom Field 11]
                  , [Custom Field 12]
                  , [Custom Field 13]
                  , [Custom Field 14]
                  , [Custom Field 15]
                  , [Custom Field 16]
                  , [Custom Field 17]
                  , [Custom Field 18]
                  , [Custom Field 19]
                  , [Custom Field 20]
                  , [Custom Field 21]
                  , [Custom Field 22]
                  , [Custom Field 23]
                  , [Custom Field 24]
                  , [Custom Field 25]
                  , [Custom Field 26]
                  , [Custom Field 27]
                  , [Custom Field 28]
                  , [Custom Field 29]
                  , [Custom Field 30]
                  , [Additional Fields for CRT lookups]
                  , [termination_dt]
                  , [action]
                  , [action_dt]
                  , HASHBYTES('md5', CONCAT([EMPLID], [DEPTID], [VC_CODE], [hr_status], [empl_Status], [termination_dt], [action], [action_dt])) AS [hash_value]
                  , GETDATE() as [Update_DT]
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
            WHERE [NON_UKG_MANAGER_FLAG]='T'
                OR ([Manager Flag]='T' AND [Person Number] IN (
                       SELECT emplid
                FROM STAGE.CTE_EXCLUDE_BYA
                   ))
        )
    -- replaced MERGE with INSERT to avoid MERGE parsing issues
    INSERT INTO [dbo].[NON_UKG_MANAGER_HISTORY]
        (
        [DEPTID]
        , [VC_CODE]
        , [FDM_COMBO_CD]
        , [COMBOCODE]
        , [REPORTS_TO]
        , [MANAGER_EMPLID]
        , [NON_UKG_MANAGER_FLAG]
        , [position_nbr]
        , [EMPLID]
        , [EMPL_RCD]
        , [jobcode]
        , [POSITION_DESCR]
        , [hr_status]
        , [FTE_SUM]
        , [fte]
        , [empl_Status]
        , [JobGroup]
        , [FundGroup]
        , [Person Number]
        , [First Name]
        , [Last Name]
        , [Middle Initial/Name]
        , [Short Name]
        , [Badge Number]
        , [Hire Date]
        , [Birth Date]
        , [Seniority Date]
        , [Manager Flag]
        , [Phone 1]
        , [Phone 2]
        , [Email]
        , [Address]
        , [City]
        , [State]
        , [Postal Code]
        , [Country]
        , [Time Zone]
        , [Employment Status]
        , [Employment Status Effective Date]
        , [Reports to Manager]
        , [Union Code]
        , [Employee Type]
        , [Employee Classification]
        , [Pay Frequency]
        , [Worker Type]
        , [FTE %]
        , [FTE Standard Hours]
        , [FTE Full Time Hours]
        , [Standard Hours - Daily]
        , [Standard Hours - Weekly]
        , [Standard Hours - Pay Period]
        , [Base Wage Rate]
        , [Base Wage Rate Effective Date]
        , [User Account Name]
        , [User Account Status]
        , [User Password]
        , [Home Business Structure Level 1 - Organization]
        , [Home Business Structure Level 2 - Entity]
        , [Home Business Structure Level 3 - Service Line]
        , [Home Business Structure Level 4 - Financial Unit]
        , [Home Business Structure Level 5 - Fund Group]
        , [Home Business Structure Level 6]
        , [Home Business Structure Level 7]
        , [Home Business Structure Level 8]
        , [Home Business Structure Level 9]
        , [Home/Primary Job]
        , [Home Labor Category Level 1]
        , [Home Labor Category Level 2]
        , [Home Labor Category Level 3]
        , [Home Labor Category Level 4]
        , [Home Labor Category Level 5]
        , [Home Labor Category Level 6]
        , [Home Job and Labor Category Effective Date]
        , [Custom Field 1]
        , [Custom Field 2]
        , [Custom Field 3]
        , [Custom Field 4]
        , [Custom Field 5]
        , [Custom Field 6]
        , [Custom Field 7]
        , [Custom Field 8]
        , [Custom Field 9]
        , [Custom Field 10]
        , [Custom Date 1]
        , [Custom Date 2]
        , [Custom Date 3]
        , [Custom Date 4]
        , [Custom Date 5]
        , [Custom Field 11]
        , [Custom Field 12]
        , [Custom Field 13]
        , [Custom Field 14]
        , [Custom Field 15]
        , [Custom Field 16]
        , [Custom Field 17]
        , [Custom Field 18]
        , [Custom Field 19]
        , [Custom Field 20]
        , [Custom Field 21]
        , [Custom Field 22]
        , [Custom Field 23]
        , [Custom Field 24]
        , [Custom Field 25]
        , [Custom Field 26]
        , [Custom Field 27]
        , [Custom Field 28]
        , [Custom Field 29]
        , [Custom Field 30]
        , [Additional Fields for CRT lookups]
        , [termination_dt]
        , [action]
        , [action_dt]
        , [hash_value]
        , [Update_DT]
        )
    SELECT
        [DEPTID]
        , [VC_CODE]
        , [FDM_COMBO_CD]
        , [COMBOCODE]
        , [REPORTS_TO]
        , [MANAGER_EMPLID]
        , [NON_UKG_MANAGER_FLAG]
        , [position_nbr]
        , [EMPLID]
        , [EMPL_RCD]
        , [jobcode]
        , [POSITION_DESCR]
        , [hr_status]
        , [FTE_SUM]
        , [fte]
        , [empl_Status]
        , [JobGroup]
        , [FundGroup]
        , [Person Number]
        , [First Name]
        , [Last Name]
        , [Middle Initial/Name]
        , [Short Name]
        , [Badge Number]
        , [Hire Date]
        , [Birth Date]
        , [Seniority Date]
        , [Manager Flag]
        , [Phone 1]
        , [Phone 2]
        , [Email]
        , [Address]
        , [City]
        , [State]
        , [Postal Code]
        , [Country]
        , [Time Zone]
        , [Employment Status]
        , [Employment Status Effective Date]
        , [Reports to Manager]
        , [Union Code]
        , [Employee Type]
        , [Employee Classification]
        , [Pay Frequency]
        , [Worker Type]
        , [FTE %]
        , [FTE Standard Hours]
        , [FTE Full Time Hours]
        , [Standard Hours - Daily]
        , [Standard Hours - Weekly]
        , [Standard Hours - Pay Period]
        , [Base Wage Rate]
        , [Base Wage Rate Effective Date]
        , [User Account Name]
        , [User Account Status]
        , [User Password]
        , [Home Business Structure Level 1 - Organization]
        , [Home Business Structure Level 2 - Entity]
        , [Home Business Structure Level 3 - Service Line]
        , [Home Business Structure Level 4 - Financial Unit]
        , [Home Business Structure Level 5 - Fund Group]
        , [Home Business Structure Level 6]
        , [Home Business Structure Level 7]
        , [Home Business Structure Level 8]
        , [Home Business Structure Level 9]
        , [Home/Primary Job]
        , [Home Labor Category Level 1]
        , [Home Labor Category Level 2]
        , [Home Labor Category Level 3]
        , [Home Labor Category Level 4]
        , [Home Labor Category Level 5]
        , [Home Labor Category Level 6]
        , [Home Job and Labor Category Effective Date]
        , [Custom Field 1]
        , [Custom Field 2]
        , [Custom Field 3]
        , [Custom Field 4]
        , [Custom Field 5]
        , [Custom Field 6]
        , [Custom Field 7]
        , [Custom Field 8]
        , [Custom Field 9]
        , [Custom Field 10]
        , [Custom Date 1]
        , [Custom Date 2]
        , [Custom Date 3]
        , [Custom Date 4]
        , [Custom Date 5]
        , [Custom Field 11]
        , [Custom Field 12]
        , [Custom Field 13]
        , [Custom Field 14]
        , [Custom Field 15]
        , [Custom Field 16]
        , [Custom Field 17]
        , [Custom Field 18]
        , [Custom Field 19]
        , [Custom Field 20]
        , [Custom Field 21]
        , [Custom Field 22]
        , [Custom Field 23]
        , [Custom Field 24]
        , [Custom Field 25]
        , [Custom Field 26]
        , [Custom Field 27]
        , [Custom Field 28]
        , [Custom Field 29]
        , [Custom Field 30]
        , [Additional Fields for CRT lookups]
        , [termination_dt]
        , [action]
        , [action_dt]
        , [hash_value]
        , [Update_DT]
    FROM SourceData S
    WHERE NOT EXISTS (
            SELECT 1
    FROM [dbo].[NON_UKG_MANAGER_HISTORY] T
    WHERE T.[Person Number] = S.[Person Number] AND T.[Manager Flag] = S.[Manager Flag]
        );

        -- end MERGE
        ;

        SET @RecordsInserted = @@ROWCOUNT;
        
        -- Update Custom Field 9 to 'T' for all manager records
        UPDATE [dbo].[NON_UKG_MANAGER_HISTORY]
        SET [Custom Field 9] = 'T'
        WHERE [Manager Flag] = 'T';
        
        -- Mark rows T.[NOTE] = 'P', not present in the source, will be updated to 'D' as deleted (active only), in SSIS
        UPDATE T
        SET T.[Employment Status] = 'T'
        ,T.[Manager Flag]= 'F'
            , T.[Employment Status Effective Date] = FORMAT(GETDATE(), 'yyyy-MM-dd')
            , T.[Update_DT] = GETDATE()
            , T.[NOTE] = 'P'
        FROM [dbo].[NON_UKG_MANAGER_HISTORY] T
        LEFT JOIN (
            SELECT [Person Number], [Manager Flag]
        FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
        WHERE [NON_UKG_MANAGER_FLAG] = 'T'
            OR ([Manager Flag] = 'T' AND [Person Number] IN (SELECT emplid
            FROM STAGE.CTE_EXCLUDE_BYA))
        ) S
        ON T.[Person Number] = S.[Person Number]
            AND T.[Manager Flag] = S.[Manager Flag]
        WHERE S.[Person Number] IS NULL
        AND T.[NOTE] IS NULL;

        SET @RecordsDeleted = @@ROWCOUNT;

        -- Mark NOTE='P' when source EMPLID matches target EMPLID and NON_UKG_MANAGER_FLAG changes from 'T' to 'F'; excluded rows where NOTE='D'.
        UPDATE T
        SET T.[NOTE] = 'P',
            T.[Update_DT] = GETDATE()
        FROM [dbo].[NON_UKG_MANAGER_HISTORY] T
        JOIN [dbo].[UKG_EMPLOYEE_DATA_TEMP] S
        ON T.[EMPLID] = S.[EMPLID]
        WHERE T.[NON_UKG_MANAGER_FLAG] = 'T'
        AND S.[NON_UKG_MANAGER_FLAG] = 'F'
        AND ISNULL(T.[NOTE], '') <> 'D';

        COMMIT TRANSACTION;
        
        -- Return summary information
        SELECT
        'NON_UKG_MANAGER_HISTORY Merge Completed' AS Status,
        @RecordsInserted AS RecordsInserted,
        @RecordsDeleted AS RecordsDeleted,
        GETDATE() AS CompletedDateTime;
            
        -- Show sample of inserted records for verification
        IF @RecordsInserted > 0
        BEGIN
        PRINT 'Sample of newly inserted records:';
        SELECT TOP 10
            [Person Number],
            [EMPLID],
            [First Name] + ' ' + [Last Name] AS Employee_Name,
            [Manager Flag],
            [NON_UKG_MANAGER_FLAG],
            [position_nbr],
            [Update_DT]
        FROM [dbo].[NON_UKG_MANAGER_HISTORY]
        WHERE [Update_DT] >= DATEADD(MINUTE, -5, GETDATE())
        ORDER BY [Update_DT] DESC;
    END
        ELSE
        BEGIN
        PRINT 'No new records to insert - all records already exist based on composite key match.';
    END
          
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ErrorMessage = ERROR_MESSAGE();
        
        SELECT
        'NON_UKG_MANAGER_HISTORY Merge Failed' AS Status,
        @ErrorMessage AS ErrorMessage,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        GETDATE() AS ErrorDateTime;
            
        -- Re-raise the error
        THROW;
    END CATCH
END
GO
