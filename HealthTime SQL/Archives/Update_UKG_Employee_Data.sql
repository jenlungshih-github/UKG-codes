/****** Update UKG_EMPLOYEE_DATA based on Inactive Manager Hierarchy Analysis ******/

BEGIN TRANSACTION;

BEGIN TRY
    -- Create a temp table to store the hierarchy data for reuse
    IF OBJECT_ID('tempdb..#InactiveManagerHierarchy', 'U') IS NOT NULL 
        DROP TABLE #InactiveManagerHierarchy;

    -- CTE based on 19.sql query - insert into temp table
    WITH
    InactiveManagerHierarchy
    AS
    (
                    SELECT
                I.[POSITION_NBR_To_Check] as POSITION_NBR,
                H.POSITION_NBR_To_Check,
                H.[MANAGER_POSITION_NBR],
                H.[POSN_LEVEL]
            FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
                LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                ON I.[POSITION_NBR_To_Check] = H.[POSITION_NBR_To_Check]
            WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                AND H.To_Trace_Up_1 = 'no'

        UNION

            SELECT
                I.[POSITION_NBR_To_Check] as POSITION_NBR,
                H.POSITION_NBR_To_Check,
                H.[MANAGER_POSITION_NBR_L1],
                H.[MANAGER_POSN_LEVEL_L1]
            FROM [HealthTime].[stage].[UKG_EMPL_Inactive_Manager] I
                LEFT JOIN [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                ON I.[POSITION_NBR_To_Check] = H.[POSITION_NBR_To_Check]
            WHERE H.[MANAGER_POSN_LEVEL_L1] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                AND H.To_Trace_Up_1 = 'yes' and H.To_Trace_Up_2='no' and H.NOTE_L1 IS NULL
    )
SELECT
    POSITION_NBR,
    POSITION_NBR_To_Check,
    MANAGER_POSITION_NBR,
    POSN_LEVEL
INTO #InactiveManagerHierarchy
FROM InactiveManagerHierarchy;

-- Show records that will be updated before the update
SELECT
    'Records to be updated:' AS Info,
    empl.[Reports_to] AS Current_Reports_To,
    CTE.MANAGER_POSITION_NBR AS New_Reports_To,
    empl.[EMPLID] AS Employee_ID,
    empl.[First Name] + ', ' + empl.[Last Name] AS Employee_Name,
    CTE.POSN_LEVEL
FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN #InactiveManagerHierarchy CTE
    ON CTE.POSITION_NBR_To_Check = empl.[Reports_to];
    
    -- Capture count before update
    DECLARE @RecordsToUpdate INT;
    SELECT @RecordsToUpdate = COUNT(*)
FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN #InactiveManagerHierarchy CTE
    ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];
    
    PRINT 'Number of records to update: ' + CAST(@RecordsToUpdate AS VARCHAR(10));
    
    -- Perform the update
    UPDATE empl
    SET 
        [Reports to Manager] = CTE.MANAGER_POSITION_NBR
    FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN #InactiveManagerHierarchy CTE
    ON CTE.POSITION_NBR_To_Check = empl.[Reports to Manager];
    
    -- Verify the update
    DECLARE @RecordsUpdated INT = @@ROWCOUNT;
    PRINT 'Number of records updated: ' + CAST(@RecordsUpdated AS VARCHAR(10));
    
    -- Check if expected number of records were updated
    IF @RecordsUpdated <> @RecordsToUpdate
    BEGIN
    PRINT 'ERROR: Mismatch in expected vs actual updated records!';
    PRINT 'Expected: ' + CAST(@RecordsToUpdate AS VARCHAR(10));
    PRINT 'Actual: ' + CAST(@RecordsUpdated AS VARCHAR(10));
    ROLLBACK TRANSACTION;
    RETURN;
END
    
    -- Show updated records for verification
    PRINT 'Updated records verification:';
    SELECT TOP 10
    empl.[Reports to Manager] AS Updated_Reports_To,
    empl.[EMPLID] AS Employee_ID,
    empl.[First Name] + ', ' + empl.[Last Name] AS Employee_Name
FROM [dbo].[UKG_EMPLOYEE_DATA] empl
    INNER JOIN #InactiveManagerHierarchy CTE
    ON CTE.MANAGER_POSITION_NBR = empl.[Reports to Manager];
    
    -- Clean up temp table
    IF OBJECT_ID('tempdb..#InactiveManagerHierarchy', 'U') IS NOT NULL 
        DROP TABLE #InactiveManagerHierarchy;
    
    -- Commit the transaction if everything is successful
    COMMIT TRANSACTION;
    PRINT 'Transaction committed successfully. ' + CAST(@RecordsUpdated AS VARCHAR(10)) + ' records updated.';
    
END TRY
BEGIN CATCH
    -- Rollback transaction in case of error
    ROLLBACK TRANSACTION;
    
    -- Display error information
    PRINT 'Error occurred during update. Transaction rolled back.';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    
    -- Re-throw the error
    THROW;
END CATCH;
