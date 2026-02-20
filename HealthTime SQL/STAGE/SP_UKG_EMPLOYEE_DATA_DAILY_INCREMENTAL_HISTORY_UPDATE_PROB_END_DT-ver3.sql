-- ==========================================================================================
-- Stored Procedure Name: SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT
-- Description: Updates the [Custom Date 1] column in the UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY table
--              with the uc_prob_end_dt value from the stage.UKG_probation_dt_retain_lookup_V view.
--              Also updates the [NOTE] column with a message indicating the update and timestamp.
-- Created By: Jim Shih
-- Created On: 2026-01-28
-- Version: 1.2
-- Updated: 2026-02-19 Jim Shih - Skip rows where NOTE = 'D' (do not update deleted rows); minor wording in NOTE message
-- ==========================================================================================
CREATE or alter PROCEDURE stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update the [Custom Date 1] and [NOTE] columns
        UPDATE [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        SET 
            [Custom Date 1] = DATEADD(DAY, 1, lookup.uc_prob_end_dt),
            [NOTE] = CONCAT('U, Custom Date 1 has retained prob_end_dt and was updated on ', CONVERT(VARCHAR, GETDATE(), 120))
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] history
        JOIN health_ods.[health_ods].stage.UKG_probation_dt_retain_lookup_V lookup
        ON history.position_nbr = lookup.position_nbr
        WHERE history.position_nbr IS NOT NULL
        AND (history.[NOTE] IS NULL OR history.[NOTE] NOT LIKE 'U, Custom Date 1 has retained prob_end_dt%')
        AND ISNULL(history.[NOTE], '') <> 'D';

        -- Commit the transaction
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Raise the error
        THROW;
    END CATCH;
END;
GO

-- ==========================================================================================
-- Technical Details:
-- - This stored procedure updates the [Custom Date 1] column in the UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY table.
-- - The update is based on a join with the stage.UKG_probation_dt_retain_lookup_V view using the position_nbr column.
-- - The [NOTE] column is updated with a message indicating the update and includes the current timestamp.
-- - The procedure uses a TRY-CATCH block to handle errors and ensures transaction integrity.

-- Version History:
-- Version 1.2 (2026-02-19): Skip rows where NOTE = 'D' (do not update deleted rows); clarified NOTE text.
-- Version 1.1 (2026-01-28): Updated to only modify rows where NOTE does not already contain the probation retention message.
-- Version 1.0 (2026-01-28): Initial creation of the stored procedure by Jim Shih.
-- ==========================================================================================