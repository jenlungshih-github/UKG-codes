-- Remove duplicate records in [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
-- Keep NOTE='D' rows when present for an EMPLID+hash_value, then keep only the oldest snapshot_date per (EMPLID, hash_value, NOTE)
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Create a backup of duplicates (optional)
    IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

    ;WITH
    base
    AS
    (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date_TXT ASC, snapshot_date ASC) AS rn_note,
            SUM(CASE WHEN ISNULL(NOTE,'') = 'D' THEN 1 ELSE 0 END) OVER (PARTITION BY EMPLID, hash_value) AS cnt_d
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
    ),
    to_remove
    AS
    (
        -- remove rows that are not the oldest within their NOTE group (rn_note > 1)
        -- and remove non-D rows when a D exists for same EMPLID+hash_value
        SELECT *
        FROM base
        WHERE rn_note > 1
            OR (cnt_d > 0 AND ISNULL(NOTE,'') <> 'D')
    )
SELECT *
INTO #dups_backup
FROM to_remove;

    DECLARE @dupCount INT = (SELECT COUNT(*)
FROM #dups_backup);
    PRINT 'Duplicate rows identified (to delete): ' + CAST(@dupCount AS VARCHAR(20));

    IF @dupCount > 0
    BEGIN
    -- delete duplicates per the above rules
    ;WITH
        base_del
        AS
        (
            SELECT *,
                ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date_TXT ASC, snapshot_date ASC) AS rn_note,
                SUM(CASE WHEN ISNULL(NOTE,'') = 'D' THEN 1 ELSE 0 END) OVER (PARTITION BY EMPLID, hash_value) AS cnt_d
            FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        ),
        del
        AS
        (
            SELECT *
            FROM base_del
            WHERE rn_note > 1
                OR (cnt_d > 0 AND ISNULL(NOTE,'') <> 'D')
        )
        DELETE FROM del;

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
    SELECT --TOP 100
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