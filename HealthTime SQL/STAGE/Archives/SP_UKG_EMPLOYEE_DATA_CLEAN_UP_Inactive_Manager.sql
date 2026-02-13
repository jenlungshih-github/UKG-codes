CREATE OR ALTER PROCEDURE [stage].[UKG_EMPLOYEE_DATA_CLEAN_UP_Inactive_Manager]
AS
-- Example execution:
-- EXEC [stage].[UKG_EMPLOYEE_DATA_CLEAN_UP_Inactive_Manager]
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsUpdated INT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);

    BEGIN TRY
        BEGIN TRANSACTION;
        
        PRINT 'Starting UKG_EMPLOYEE_DATA cleanup for inactive managers...';
        
        -- Update UKG_EMPLOYEE_DATA based on BCK.empl_to_check data
        -- Only update records where there's a mismatch
        UPDATE ukg_empl
        SET ukg_empl.[Reports_to] = etc.[Reports_To]
        FROM [dbo].[UKG_EMPLOYEE_DATA] ukg_empl
        INNER JOIN [BCK].[empl_to_check] etc
        ON etc.[emplid] = ukg_empl.EMPLID
        WHERE 
            -- Only update where Reports_to values are different
            ukg_empl.[Reports_to] != etc.[Reports_To]
        -- Ensure the employee exists in both tables
        AND ukg_empl.EMPLID IS NOT NULL
        AND etc.[emplid] IS NOT NULL;
        
        SET @RowsUpdated = @@ROWCOUNT;
        
        PRINT 'Rows updated: ' + CAST(@RowsUpdated AS VARCHAR(10));
        
        -- Log the changes for audit purposes
        PRINT 'Summary of updates:';
        SELECT
        etc.[emplid] AS Updated_EMPLID,
        etc.[name] AS Employee_Name,
        ukg_empl.[Reports_to] AS New_Reports_To,
        etc.[Reports_To] AS Source_Reports_To,
        etc.[POSITION_NBR_To_Check],
        etc.[Inactive_Manager_EMPLID],
        etc.[Inactive_Manager_Termination_Date]
    FROM [dbo].[UKG_EMPLOYEE_DATA] ukg_empl
        INNER JOIN [BCK].[empl_to_check] etc
        ON etc.[emplid] = ukg_empl.EMPLID
    WHERE 
            ukg_empl.[Reports_to] = etc.[Reports_To]; -- Show records that now match
        
        COMMIT TRANSACTION;
        
        PRINT 'UKG_EMPLOYEE_DATA cleanup completed successfully.';
        PRINT 'Total records updated: ' + CAST(@RowsUpdated AS VARCHAR(10));
        
        -- Delete duplicate employee records with FTE = 0
        PRINT 'Starting deletion of duplicate employee records with FTE = 0...';
        
        DECLARE @RowsDeleted INT = 0;
        
        WITH
        duplicate_employees
        AS
        (
            SELECT emplid, count(emplid) as emp_count
            FROM [dbo].[UKG_EMPLOYEE_DATA]
            GROUP BY emplid
            HAVING count(emplid) > 1
        ),
        records_to_delete
        AS
        (
            SELECT
                empl.emplid,
                empl.position_nbr,
                empl.FTE
            FROM duplicate_employees cte
                JOIN [dbo].[UKG_EMPLOYEE_DATA] empl
                ON empl.emplid = cte.emplid
            WHERE empl.FTE = 0
        )
        DELETE ukg_empl
        FROM [dbo].[UKG_EMPLOYEE_DATA] ukg_empl
        JOIN records_to_delete rtd
        ON ukg_empl.emplid = rtd.emplid
            AND ukg_empl.position_nbr = rtd.position_nbr;
        
        SET @RowsDeleted = @@ROWCOUNT;
        
        PRINT 'Duplicate records with FTE = 0 deleted: ' + CAST(@RowsDeleted AS VARCHAR(10));
        PRINT 'Total cleanup operations completed successfully.';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        SET @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error occurred during UKG_EMPLOYEE_DATA cleanup: ' + @ErrorMessage;
        
        -- Re-throw the error
        THROW;
    END CATCH
END
GO


