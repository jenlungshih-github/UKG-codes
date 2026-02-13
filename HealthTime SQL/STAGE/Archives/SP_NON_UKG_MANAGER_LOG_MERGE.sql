/***************************************
* Stored Procedure: [stage].[SP_NON_UKG_MANAGER_LOG_MERGE]
* Created By: Jim Shih
* Created Date: 12/01/2025
* Purpose: Merges Non-UKG Manager employee data into the NON_UKG_MANAGER_LOG table
*          Handles employees who are managers but not in the main UKG system
* Logic: 
*   1. Sources data from [dbo].[UKG_EMPLOYEE_DATA] where:
*      a) [NON_UKG_MANAGER_FLAG]='T', OR
*      b) [Manager Flag]='T' AND [Person Number] exists in STAGE.CTE_EXCLUDE_BYA
*   2. Uses MERGE operation to prevent duplicate entries
*   3. Matches on composite key: [Person Number] AND [Manager Flag]
*   4. Only inserts new records when no match exists (WHEN NOT MATCHED BY TARGET)
*   5. Sets Email field to blank for testing purposes
*   6. Includes all 83 employee data fields plus custom fields and dates
*   7. Provides transaction management and error handling
*   8. Returns summary of affected records for audit purposes
* 
* Business Context:
*   - Manages employees who have manager responsibilities but are not in main UKG system
*   - Captures managers excluded from standard UKG processing due to BYA criteria
*   - Ensures data integrity by preventing duplicate manager records
*   - Supports hybrid workforce management between UKG and non-UKG systems
*   - Maintains complete employee profile data for reporting and compliance
*
* Usage: EXEC [stage].[SP_NON_UKG_MANAGER_LOG_MERGE]
* 
* Version History:
*   v1.0 - 12/01/2025 - Jim Shih: Initial creation
*                      - Converted from direct MERGE statement to stored procedure
*                      - Added comprehensive error handling and transaction management
*                      - Included audit trail with row count and summary reporting
*                      - Added detailed documentation for business logic
*   v1.1 - 12/01/2025 - Jim Shih: Enhanced source data selection logic
*                      - Added OR condition for managers in CTE_EXCLUDE_BYA table
*                      - Captures managers excluded from UKG due to BYA business rules
*                      - Updated verification query to match new selection criteria
******************************************/

CREATE OR ALTER PROCEDURE [stage].[SP_NON_UKG_MANAGER_LOG_MERGE]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsInserted INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @StartTime DATETIME2 = GETDATE();

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Perform MERGE operation to insert Non-UKG Manager records
        MERGE [stage].[NON_UKG_MANAGER_LOG] AS Target
        USING (
            SELECT DISTINCT
        [Person Number]
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
                , '' as [Email]  --make email blank until ready for testing
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
                , [Custom Date 1] -- re-order after [Custom Field 10]
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
    FROM dbo.[UKG_EMPLOYEE_DATA]
    WHERE [NON_UKG_MANAGER_FLAG]='T'
        OR ([Manager Flag]='T' AND [Person Number] IN (
           SELECT emplid
        FROM STAGE.CTE_EXCLUDE_BYA
       ))
        ) AS Source
        ON Target.[Person Number] = Source.[Person Number]
        AND Target.[Manager Flag] = Source.[Manager Flag]
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                [Person Number]
                ,[First Name]
                ,[Last Name]
                ,[Middle Initial/Name]
                ,[Short Name]
                ,[Badge Number]
                ,[Hire Date]
                ,[Birth Date]
                ,[Seniority Date]
                ,[Manager Flag]
                ,[Phone 1]
                ,[Phone 2]
                ,[Email]
                ,[Address]
                ,[City]
                ,[State]
                ,[Postal Code]
                ,[Country]
                ,[Time Zone]
                ,[Employment Status]
                ,[Employment Status Effective Date]
                ,[Reports to Manager]
                ,[Union Code]
                ,[Employee Type]
                ,[Employee Classification]
                ,[Pay Frequency]
                ,[Worker Type]
                ,[FTE %]
                ,[FTE Standard Hours]
                ,[FTE Full Time Hours]
                ,[Standard Hours - Daily]
                ,[Standard Hours - Weekly]
                ,[Standard Hours - Pay Period]
                ,[Base Wage Rate]
                ,[Base Wage Rate Effective Date]
                ,[User Account Name]
                ,[User Account Status]
                ,[User Password]
                ,[Home Business Structure Level 1 - Organization]
                ,[Home Business Structure Level 2 - Entity]
                ,[Home Business Structure Level 3 - Service Line]
                ,[Home Business Structure Level 4 - Financial Unit]
                ,[Home Business Structure Level 5 - Fund Group]
                ,[Home Business Structure Level 6]
                ,[Home Business Structure Level 7]
                ,[Home Business Structure Level 8]
                ,[Home Business Structure Level 9]
                ,[Home/Primary Job]
                ,[Home Labor Category Level 1]
                ,[Home Labor Category Level 2]
                ,[Home Labor Category Level 3]
                ,[Home Labor Category Level 4]
                ,[Home Labor Category Level 5]
                ,[Home Labor Category Level 6]
                ,[Home Job and Labor Category Effective Date]
                ,[Custom Field 1]
                ,[Custom Field 2]
                ,[Custom Field 3]
                ,[Custom Field 4]
                ,[Custom Field 5]
                ,[Custom Field 6]
                ,[Custom Field 7]
                ,[Custom Field 8]
                ,[Custom Field 9]
                ,[Custom Field 10]
                ,[Custom Date 1]
                ,[Custom Date 2]
                ,[Custom Date 3]
                ,[Custom Date 4]
                ,[Custom Date 5]
                ,[Custom Field 11]
                ,[Custom Field 12]
                ,[Custom Field 13]
                ,[Custom Field 14]
                ,[Custom Field 15]
                ,[Custom Field 16]
                ,[Custom Field 17]
                ,[Custom Field 18]
                ,[Custom Field 19]
                ,[Custom Field 20]
                ,[Custom Field 21]
                ,[Custom Field 22]
                ,[Custom Field 23]
                ,[Custom Field 24]
                ,[Custom Field 25]
                ,[Custom Field 26]
                ,[Custom Field 27]
                ,[Custom Field 28]
                ,[Custom Field 29]
                ,[Custom Field 30]
                ,[Additional Fields for CRT lookups]
            )
            VALUES (
                Source.[Person Number]
                ,Source.[First Name]
                ,Source.[Last Name]
                ,Source.[Middle Initial/Name]
                ,Source.[Short Name]
                ,Source.[Badge Number]
                ,Source.[Hire Date]
                ,Source.[Birth Date]
                ,Source.[Seniority Date]
                ,Source.[Manager Flag]
                ,Source.[Phone 1]
                ,Source.[Phone 2]
                ,Source.[Email]
                ,Source.[Address]
                ,Source.[City]
                ,Source.[State]
                ,Source.[Postal Code]
                ,Source.[Country]
                ,Source.[Time Zone]
                ,Source.[Employment Status]
                ,Source.[Employment Status Effective Date]
                ,Source.[Reports to Manager]
                ,Source.[Union Code]
                ,Source.[Employee Type]
                ,Source.[Employee Classification]
                ,Source.[Pay Frequency]
                ,Source.[Worker Type]
                ,Source.[FTE %]
                ,Source.[FTE Standard Hours]
                ,Source.[FTE Full Time Hours]
                ,Source.[Standard Hours - Daily]
                ,Source.[Standard Hours - Weekly]
                ,Source.[Standard Hours - Pay Period]
                ,Source.[Base Wage Rate]
                ,Source.[Base Wage Rate Effective Date]
                ,Source.[User Account Name]
                ,Source.[User Account Status]
                ,Source.[User Password]
                ,Source.[Home Business Structure Level 1 - Organization]
                ,Source.[Home Business Structure Level 2 - Entity]
                ,Source.[Home Business Structure Level 3 - Service Line]
                ,Source.[Home Business Structure Level 4 - Financial Unit]
                ,Source.[Home Business Structure Level 5 - Fund Group]
                ,Source.[Home Business Structure Level 6]
                ,Source.[Home Business Structure Level 7]
                ,Source.[Home Business Structure Level 8]
                ,Source.[Home Business Structure Level 9]
                ,Source.[Home/Primary Job]
                ,Source.[Home Labor Category Level 1]
                ,Source.[Home Labor Category Level 2]
                ,Source.[Home Labor Category Level 3]
                ,Source.[Home Labor Category Level 4]
                ,Source.[Home Labor Category Level 5]
                ,Source.[Home Labor Category Level 6]
                ,Source.[Home Job and Labor Category Effective Date]
                ,Source.[Custom Field 1]
                ,Source.[Custom Field 2]
                ,Source.[Custom Field 3]
                ,Source.[Custom Field 4]
                ,Source.[Custom Field 5]
                ,Source.[Custom Field 6]
                ,Source.[Custom Field 7]
                ,Source.[Custom Field 8]
                ,Source.[Custom Field 9]
                ,Source.[Custom Field 10]
                ,Source.[Custom Date 1]
                ,Source.[Custom Date 2]
                ,Source.[Custom Date 3]
                ,Source.[Custom Date 4]
                ,Source.[Custom Date 5]
                ,Source.[Custom Field 11]
                ,Source.[Custom Field 12]
                ,Source.[Custom Field 13]
                ,Source.[Custom Field 14]
                ,Source.[Custom Field 15]
                ,Source.[Custom Field 16]
                ,Source.[Custom Field 17]
                ,Source.[Custom Field 18]
                ,Source.[Custom Field 19]
                ,Source.[Custom Field 20]
                ,Source.[Custom Field 21]
                ,Source.[Custom Field 22]
                ,Source.[Custom Field 23]
                ,Source.[Custom Field 24]
                ,Source.[Custom Field 25]
                ,Source.[Custom Field 26]
                ,Source.[Custom Field 27]
                ,Source.[Custom Field 28]
                ,Source.[Custom Field 29]
                ,Source.[Custom Field 30]
                ,Source.[Additional Fields for CRT lookups]
            );
        
        SET @RowsInserted = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return summary information
        SELECT
        'Non-UKG Manager Log Merge Completed' AS Status,
        @RowsInserted AS RowsInserted,
        @StartTime AS StartTime,
        GETDATE() AS CompletedDateTime,
        DATEDIFF(SECOND, @StartTime, GETDATE()) AS DurationSeconds;
            
        -- Show sample of inserted records for verification (limit to 10)
        SELECT TOP 10
        [Person Number],
        [First Name],
        [Last Name],
        [Manager Flag],
        [Employment Status],
        [Home Business Structure Level 1 - Organization],
        [Home Business Structure Level 4 - Financial Unit],
        'Inserted by SP_NON_UKG_MANAGER_LOG_MERGE' AS InsertedBy
    FROM [stage].[NON_UKG_MANAGER_LOG]
    WHERE [Person Number] IN (
            SELECT [Person Number]
    FROM dbo.[UKG_EMPLOYEE_DATA]
    WHERE [NON_UKG_MANAGER_FLAG]='T'
        OR ([Manager Flag]='T' AND [Person Number] IN (
           SELECT emplid
        FROM STAGE.CTE_EXCLUDE_BYA
       ))
        )
    ORDER BY [Last Name], [First Name];
          
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ErrorMessage = ERROR_MESSAGE();
        
        SELECT
        'Non-UKG Manager Log Merge Failed' AS Status,
        @ErrorMessage AS ErrorMessage,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        @StartTime AS StartTime,
        GETDATE() AS ErrorDateTime;
            
        -- Re-raise the error
        THROW;
    END CATCH
END
GO
