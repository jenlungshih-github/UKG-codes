-- Full-table dedupe for dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
-- IDENTIFIES duplicate rows per (EMPLID, hash_value, NOTE) and optionally deletes extras
-- Keeps the oldest snapshot_date_TXT (and snapshot_date) for each group
-- Default: dry-run. Set @execute = 1 to perform deletion.

SET NOCOUNT ON;

DECLARE @execute BIT = 0;
-- 0 = dry-run, 1 = perform delete
DECLARE @rowsToDelete INT = 0;

PRINT 'Starting full-table duplicate identification (dry-run = ' + CAST(@execute AS varchar(1)) + ')';

-- Create a backup of duplicates into temp table
IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

;
WITH
    cte
    AS
    (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value ORDER BY snapshot_date_TXT ASC, snapshot_date ASC) AS rn
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
    )
SELECT *
INTO #dups_backup
FROM cte
WHERE rn > 1;

SELECT @rowsToDelete = COUNT(*)
FROM #dups_backup;
PRINT 'Duplicate rows identified (candidates for deletion): ' + CAST(@rowsToDelete AS varchar(20));

-- Show sample of duplicates
IF @rowsToDelete > 0
BEGIN
    PRINT 'Sample duplicate rows (top 200):';
    SELECT TOP 200
        EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, hash_value
    FROM #dups_backup
    ORDER BY EMPLID, snapshot_date;
END
ELSE
BEGIN
    PRINT 'No duplicate rows found.';
END

IF @execute = 1 AND @rowsToDelete > 0
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- perform delete, keeping oldest snapshot_date_TXT
        ;WITH
        del
        AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date_TXT ASC, snapshot_date ASC) AS rn
            FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        )
        DELETE FROM del WHERE rn > 1;

        DECLARE @deleted INT = @@ROWCOUNT;
        PRINT 'Deleted rows: ' + CAST(@deleted AS varchar(20));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSev INT = ERROR_SEVERITY();
        DECLARE @ErrState INT = ERROR_STATE();
        RAISERROR(@ErrMsg, @ErrSev, @ErrState);
    END CATCH
END

-- Clean up
IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

PRINT 'Finished.';