USE [HealthTime]
GO

/****** Object:  StoredProcedure [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]    Script Date: 9/11/2025 10:43:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***************************************
* Stored Procedure: [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
* Purpose: Update "Reports to Manager" field in UKG_EMPLOYEE_DATA based on comprehensive inactive manager hierarchy analysis
* 
* Logic Overview:
* 1. Creates temporary table from inactive manager hierarchy lookup data with comprehensive multi-level tracing
* 2. Uses advanced UNION logic to handle five hierarchy scenarios:
*    - Level 0: Direct manager replacement (To_Trace_Up_1 = 'no')
*    - Level 1: One-level trace-up (To_Trace_Up_1 = 'yes', To_Trace_Up_2 = 'no')
*    - Level 2: Two-level trace-up (To_Trace_Up_1-2 = 'yes', To_Trace_Up_3 = 'no')
*    - Level 3: Three-level trace-up (To_Trace_Up_1-3 = 'yes', To_Trace_Up_4 = 'no')
*    - Level 4: Four-level trace-up (To_Trace_Up_1-4 = 'yes')
* 3. Updates UKG_EMPLOYEE_DATA with correct active manager information from any hierarchy level
* 4. Provides comprehensive logging, validation, and error handling throughout the process
* 
* Business Logic:
* - Filters for manager positions at LEVEL5-LEVEL9 (executive/senior management levels)
* - Handles complex scenarios where multiple management levels are inactive
* - Traces up organizational hierarchy up to 4 levels to find active managers
* - Ensures data integrity through transaction control and comprehensive validation checks
* - Provides detailed before/after verification of updated records
* 
* Multi-Level Hierarchy Processing:
* - MANAGER_POSITION_NBR: Direct manager (Level 0)
* - MANAGER_POSITION_NBR_L1: First level trace-up manager (Level 1)
* - MANAGER_POSITION_NBR_L2: Second level trace-up manager (Level 2)
* - MANAGER_POSITION_NBR_L3: Third level trace-up manager (Level 3)
* - MANAGER_POSITION_NBR_L4: Fourth level trace-up manager (Level 4)
* 
* Transaction Control:
* - Uses BEGIN/COMMIT/ROLLBACK for comprehensive data integrity
* - Validates expected vs actual record counts with detailed error reporting
* - Comprehensive error handling with detailed logging and rollback capabilities
* - Temporary table cleanup to ensure no resource leaks
* 
* Dependencies:
* - [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] - Multi-level hierarchy analysis lookup table
* - [dbo].[UKG_EMPLOYEE_DATA] - Target table for manager relationship updates
* 
* Example execution:
* EXEC [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
* 
* Created: 09/05/2025 Jim Shih
* Modified: 09/05/2025 Jim Shih - Added comprehensive multi-level hierarchy processing and documentation
******************************************/

CREATE OR ALTER PROCEDURE [stage].[SP_UKG_EMPL_DATA_Update_imgr-Step3]
AS
BEGIN
    SET NOCOUNT ON;

    /****** Update UKG_EMPLOYEE_DATA based on Inactive Manager Hierarchy Analysis ******/

    BEGIN TRANSACTION;

    BEGIN TRY
    -- Create a temp table to store the hierarchy data for reuse
    IF OBJECT_ID('tempdb..#InactiveManagerHierarchy', 'U') IS NOT NULL 
        DROP TABLE #InactiveManagerHierarchy;

    -- CTE insert into temp table
    WITH
        InactiveManagerHierarchy
        AS
        (
                                                                SELECT
                    H.POSITION_NBR_To_Check,
                    H.[MANAGER_POSITION_NBR],
                    H.[POSN_LEVEL]
                FROM
                    [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.[POSN_LEVEL] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'no'

            UNION

                SELECT
                    H.POSITION_NBR_To_Check,
                    H.[MANAGER_POSITION_NBR_L1],
                    H.[MANAGER_POSN_LEVEL_L1]
                FROM
                    [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.[MANAGER_POSN_LEVEL_L1] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes' and H.To_Trace_Up_2='no' and H.NOTE_L1 IS NULL

            UNION

                SELECT
                    H.POSITION_NBR_To_Check,
                    H.[MANAGER_POSITION_NBR_L2],
                    H.[MANAGER_POSN_LEVEL_L2]
                FROM
                    [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.[MANAGER_POSN_LEVEL_L2] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes' and H.To_Trace_Up_2='yes' and H.To_Trace_Up_3='no' and H.NOTE_L2 IS NULL

            UNION

                SELECT
                    H.POSITION_NBR_To_Check,
                    H.[MANAGER_POSITION_NBR_L3],
                    H.[MANAGER_POSN_LEVEL_L3]
                FROM
                    [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.[MANAGER_POSN_LEVEL_L3] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes' and H.To_Trace_Up_2='yes' and H.To_Trace_Up_3='yes' and H.To_Trace_Up_4='no' and H.NOTE_L3 IS NULL

            UNION

                SELECT
                    H.POSITION_NBR_To_Check,
                    H.[MANAGER_POSITION_NBR_L4],
                    H.[MANAGER_POSN_LEVEL_L4]
                FROM
                    [stage].[UKG_EMPL_Inactive_Manager_Hierarchy] H
                WHERE H.[MANAGER_POSN_LEVEL_L4] IN ('LEVEL5', 'LEVEL6', 'LEVEL7', 'LEVEL8', 'LEVEL9')
                    AND H.To_Trace_Up_1 = 'yes' and H.To_Trace_Up_2='yes' and H.To_Trace_Up_3='yes' and H.To_Trace_Up_4='yes' and H.NOTE_L4 IS NULL
        )
    SELECT
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
        --empl.[EMPLID] AS Employee_ID,
        --empl.[First Name] + ', ' + empl.[Last Name] AS Employee_Name,
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

END
GO


