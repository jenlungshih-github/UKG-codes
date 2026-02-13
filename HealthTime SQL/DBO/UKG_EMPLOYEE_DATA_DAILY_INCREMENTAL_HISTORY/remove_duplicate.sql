-- Remove duplicate records in [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
-- Keep only the oldest snapshot_date for each (EMPLID, hash_value, NOTE)
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Create a backup of duplicates (optional)
    IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

    ;WITH
    cte
    AS
    (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
    )
SELECT *
INTO #dups_backup
FROM cte
WHERE rn > 1;

    DECLARE @dupCount INT = (SELECT COUNT(*)
FROM #dups_backup);

    PRINT 'Duplicate rows identified (to delete): ' + CAST(@dupCount AS VARCHAR(20));

    IF @dupCount > 0
    BEGIN
    -- Delete duplicates, keeping the oldest (rn = 1)
    ;WITH
        cte_del
        AS
        (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
            FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        )
        DELETE FROM cte_del
        WHERE rn > 1;

    PRINT 'Deleted rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));
END
    ELSE
    BEGIN
    PRINT 'No duplicate rows found.';
END

    COMMIT TRANSACTION;

    -- Optional: show sample of removed rows
    IF @dupCount > 0
    BEGIN
    PRINT 'Sample of removed duplicate rows (from temp backup):';
    SELECT TOP 100
        EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, hash_value
    FROM #dups_backup
    ORDER BY EMPLID, snapshot_date;
END

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSev INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSev, @ErrState);
END CATCH;

-- Cleanup temp
IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;