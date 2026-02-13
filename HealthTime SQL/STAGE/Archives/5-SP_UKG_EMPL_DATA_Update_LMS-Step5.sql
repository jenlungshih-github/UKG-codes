/***************************************
* Stored Procedure: [stage].[SP_UKG_EMPL_DATA_Update_LMS-Step5]
* Created By: Jim Shih
* Created Date: 11/04/2025
* Purpose: Update Custom Field 9 to 'T' for employees where Manager Flag = 'T' 
*          OR who have an active temporary manager license
*          This is part of the LMS (Learning Management System) Step 5 process
* Logic: 
*   1. Updates [Custom Field 9] to 'T' for all records where:
*      a) [Manager Flag] = 'T', OR
*      b) Employee has an active temporary manager license in [HealthTime].[hts].[UKG_TempManagerLicense]
*         where current date is between StartDate and EndDate
*   2. Returns count of affected records for audit purposes
*   3. Shows verification results with update reason (Manager Flag, Temp License, or both)
*   4. Includes error handling and transaction management
* Usage: EXEC [stage].[SP_UKG_EMPL_DATA_Update_LMS-Step5]
* Version History:
*   v1.0 - 11/04/2025 - Jim Shih: Initial creation
*                      - Update Custom Field 9 based on Manager Flag
*                      - Added transaction management and error handling
*   v1.1 - 11/04/2025 - Jim Shih: Enhanced with temporary manager license logic
*                      - Added OR condition for UKG_TempManagerLicense table
*                      - Checks if current date is between license StartDate and EndDate
*                      - Enhanced verification query with update reason classification
******************************************/

CREATE OR ALTER PROCEDURE [stage].[SP_UKG_EMPL_DATA_Update_LMS-Step5]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsAffected INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update Custom Field 9 to 'T' where Manager Flag = 'T' OR temporary manager license is active
        UPDATE UKG
        SET [Custom Field 9] = 'T'
        FROM [dbo].[UKG_EMPLOYEE_DATA] UKG
        WHERE [Manager Flag] = 'T'
        OR EXISTS (
               SELECT 1
        FROM [HealthTime].[hts].[UKG_TempManagerLicense] LIC
        WHERE LIC.PersonNumber = UKG.[Person Number]
            AND GETDATE() BETWEEN LIC.StartDate AND LIC.EndDate
           )
--          AND ([Custom Field 9] IS NULL OR [Custom Field 9] <> 'T'); -- Only update if different
        
        SET @RowsAffected = @@ROWCOUNT;
        
        COMMIT TRANSACTION;
        
        -- Return summary information
        SELECT
        'LMS Step 5 Update Completed' AS Status,
        @RowsAffected AS RowsUpdated,
        GETDATE() AS CompletedDateTime;
            
        -- Show affected records for verification
        SELECT
        UKG.[EMPLID],
        UKG.[Person Number],
        UKG.[Manager Flag],
        UKG.[Custom Field 9],
        CASE 
                WHEN UKG.[Manager Flag] = 'T' AND EXISTS (
                    SELECT 1
            FROM [HealthTime].[hts].[UKG_TempManagerLicense] LIC
            WHERE LIC.PersonNumber = UKG.[Person Number]
                AND GETDATE() BETWEEN LIC.StartDate AND LIC.EndDate
                ) THEN 'Manager Flag + Temp License'
                WHEN UKG.[Manager Flag] = 'T' THEN 'Manager Flag Only'
                WHEN EXISTS (
                    SELECT 1
        FROM [HealthTime].[hts].[UKG_TempManagerLicense] LIC
        WHERE LIC.PersonNumber = UKG.[Person Number]
            AND GETDATE() BETWEEN LIC.StartDate AND LIC.EndDate
                ) THEN 'Temp License Only'
                ELSE 'Unknown'
            END AS UpdateReason,
        'Updated by LMS Step 5' AS UpdatedBy
    FROM [dbo].[UKG_EMPLOYEE_DATA] UKG
    WHERE ([Manager Flag] = 'T'
        OR EXISTS (
               SELECT 1
        FROM [HealthTime].[hts].[UKG_TempManagerLicense] LIC
        WHERE LIC.PersonNumber = UKG.[Person Number]
            AND GETDATE() BETWEEN LIC.StartDate AND LIC.EndDate
           ))
        AND [Custom Field 9] = 'T';
          
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @ErrorMessage = ERROR_MESSAGE();
        
        SELECT
        'LMS Step 5 Update Failed' AS Status,
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