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
* - Preserves historical snapshots with snapshot_DT timestamp
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
******************************************/

CREATE OR ALTER PROCEDURE [stage].[SP_NON_UKG_MANAGER_HISTORY_MERGE]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RecordsInserted INT = 0;
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
                  , GETDATE() as [snapshot_DT]
            FROM [dbo].[UKG_EMPLOYEE_DATA_TEMP]
            WHERE [NON_UKG_MANAGER_FLAG]='T'
                OR ([Manager Flag]='T' AND [Person Number] IN (
                       SELECT emplid
                FROM STAGE.CTE_EXCLUDE_BYA
                   ))
        )
        MERGE [dbo].[NON_UKG_MANAGER_HISTORY] AS TARGET
        USING SourceData AS SOURCE
        ON (TARGET.[Person Number] = SOURCE.[Person Number]
        AND TARGET.[Manager Flag] = SOURCE.[Manager Flag])
        
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ([DEPTID]
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
                   , [snapshot_DT])
            VALUES (SOURCE.[DEPTID]
                   , SOURCE.[VC_CODE]
                   , SOURCE.[FDM_COMBO_CD]
                   , SOURCE.[COMBOCODE]
                   , SOURCE.[REPORTS_TO]
                   , SOURCE.[MANAGER_EMPLID]
                   , SOURCE.[NON_UKG_MANAGER_FLAG]
                   , SOURCE.[position_nbr]
                   , SOURCE.[EMPLID]
                   , SOURCE.[EMPL_RCD]
                   , SOURCE.[jobcode]
                   , SOURCE.[POSITION_DESCR]
                   , SOURCE.[hr_status]
                   , SOURCE.[FTE_SUM]
                   , SOURCE.[fte]
                   , SOURCE.[empl_Status]
                   , SOURCE.[JobGroup]
                   , SOURCE.[FundGroup]
                   , SOURCE.[Person Number]
                   , SOURCE.[First Name]
                   , SOURCE.[Last Name]
                   , SOURCE.[Middle Initial/Name]
                   , SOURCE.[Short Name]
                   , SOURCE.[Badge Number]
                   , SOURCE.[Hire Date]
                   , SOURCE.[Birth Date]
                   , SOURCE.[Seniority Date]
                   , SOURCE.[Manager Flag]
                   , SOURCE.[Phone 1]
                   , SOURCE.[Phone 2]
                   , SOURCE.[Email]
                   , SOURCE.[Address]
                   , SOURCE.[City]
                   , SOURCE.[State]
                   , SOURCE.[Postal Code]
                   , SOURCE.[Country]
                   , SOURCE.[Time Zone]
                   , SOURCE.[Employment Status]
                   , SOURCE.[Employment Status Effective Date]
                   , SOURCE.[Reports to Manager]
                   , SOURCE.[Union Code]
                   , SOURCE.[Employee Type]
                   , SOURCE.[Employee Classification]
                   , SOURCE.[Pay Frequency]
                   , SOURCE.[Worker Type]
                   , SOURCE.[FTE %]
                   , SOURCE.[FTE Standard Hours]
                   , SOURCE.[FTE Full Time Hours]
                   , SOURCE.[Standard Hours - Daily]
                   , SOURCE.[Standard Hours - Weekly]
                   , SOURCE.[Standard Hours - Pay Period]
                   , SOURCE.[Base Wage Rate]
                   , SOURCE.[Base Wage Rate Effective Date]
                   , SOURCE.[User Account Name]
                   , SOURCE.[User Account Status]
                   , SOURCE.[User Password]
                   , SOURCE.[Home Business Structure Level 1 - Organization]
                   , SOURCE.[Home Business Structure Level 2 - Entity]
                   , SOURCE.[Home Business Structure Level 3 - Service Line]
                   , SOURCE.[Home Business Structure Level 4 - Financial Unit]
                   , SOURCE.[Home Business Structure Level 5 - Fund Group]
                   , SOURCE.[Home Business Structure Level 6]
                   , SOURCE.[Home Business Structure Level 7]
                   , SOURCE.[Home Business Structure Level 8]
                   , SOURCE.[Home Business Structure Level 9]
                   , SOURCE.[Home/Primary Job]
                   , SOURCE.[Home Labor Category Level 1]
                   , SOURCE.[Home Labor Category Level 2]
                   , SOURCE.[Home Labor Category Level 3]
                   , SOURCE.[Home Labor Category Level 4]
                   , SOURCE.[Home Labor Category Level 5]
                   , SOURCE.[Home Labor Category Level 6]
                   , SOURCE.[Home Job and Labor Category Effective Date]
                   , SOURCE.[Custom Field 1]
                   , SOURCE.[Custom Field 2]
                   , SOURCE.[Custom Field 3]
                   , SOURCE.[Custom Field 4]
                   , SOURCE.[Custom Field 5]
                   , SOURCE.[Custom Field 6]
                   , SOURCE.[Custom Field 7]
                   , SOURCE.[Custom Field 8]
                   , SOURCE.[Custom Field 9]
                   , SOURCE.[Custom Field 10]
                   , SOURCE.[Custom Date 1]
                   , SOURCE.[Custom Date 2]
                   , SOURCE.[Custom Date 3]
                   , SOURCE.[Custom Date 4]
                   , SOURCE.[Custom Date 5]
                   , SOURCE.[Custom Field 11]
                   , SOURCE.[Custom Field 12]
                   , SOURCE.[Custom Field 13]
                   , SOURCE.[Custom Field 14]
                   , SOURCE.[Custom Field 15]
                   , SOURCE.[Custom Field 16]
                   , SOURCE.[Custom Field 17]
                   , SOURCE.[Custom Field 18]
                   , SOURCE.[Custom Field 19]
                   , SOURCE.[Custom Field 20]
                   , SOURCE.[Custom Field 21]
                   , SOURCE.[Custom Field 22]
                   , SOURCE.[Custom Field 23]
                   , SOURCE.[Custom Field 24]
                   , SOURCE.[Custom Field 25]
                   , SOURCE.[Custom Field 26]
                   , SOURCE.[Custom Field 27]
                   , SOURCE.[Custom Field 28]
                   , SOURCE.[Custom Field 29]
                   , SOURCE.[Custom Field 30]
                   , SOURCE.[Additional Fields for CRT lookups]
                   , SOURCE.[termination_dt]
                   , SOURCE.[action]
                   , SOURCE.[action_dt]
                   , SOURCE.[snapshot_DT]);
        
        SET @RecordsInserted = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return summary information
        SELECT
        'NON_UKG_MANAGER_HISTORY Merge Completed' AS Status,
        @RecordsInserted AS RecordsInserted,
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
            [snapshot_DT]
        FROM [dbo].[NON_UKG_MANAGER_HISTORY]
        WHERE [snapshot_DT] >= DATEADD(MINUTE, -5, GETDATE())
        ORDER BY [snapshot_DT] DESC;
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
