-- Remove duplicate records for EMPLID = 10473712 in dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
-- Keep only the oldest snapshot_date for each (EMPLID, hash_value, NOTE)
SET NOCOUNT ON;

DECLARE @EMPLID VARCHAR(11) = '10473712';

PRINT '*** Pre-check: duplicates for EMPLID ' + @EMPLID + ' ***';
SELECT
    hash_value,
    NOTE,
    COUNT(*) AS occurrences,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY hash_value, NOTE
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, last_seen DESC;

PRINT 'Sample rows (pre-delete)';
SELECT TOP 200
    EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, hash_value
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
ORDER BY snapshot_date;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('tempdb..#removed_backup') IS NOT NULL DROP TABLE #removed_backup;

    ;WITH
    cte
    AS
    (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
        WHERE EMPLID = @EMPLID
    )
SELECT *
INTO #removed_backup
FROM cte
WHERE rn > 1;

    DECLARE @toRemove INT = (SELECT COUNT(*)
FROM #removed_backup);
    PRINT 'Rows to remove: ' + CAST(@toRemove AS VARCHAR(10));

    IF @toRemove > 0
    BEGIN
    ;WITH
        cte_del
        AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date ASC, snapshot_date_TXT ASC) AS rn
            FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
            WHERE EMPLID = @EMPLID
        )
        DELETE FROM cte_del WHERE rn > 1;

    PRINT 'Deleted rows: ' + CAST(@@ROWCOUNT AS VARCHAR(10));
END
    ELSE
    BEGIN
    PRINT 'No duplicate rows found for EMPLID ' + @EMPLID;
END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH;

-- Post-check
PRINT '*** Post-check: duplicates remaining (should be none) ***';
SELECT
    hash_value,
    NOTE,
    COUNT(*) AS occurrences,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY hash_value, NOTE
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, last_seen DESC;

PRINT 'Sample rows (post-delete)';
SELECT TOP 200
    EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, hash_value
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
ORDER BY snapshot_date;

IF OBJECT_ID('tempdb..#removed_backup') IS NOT NULL DROP TABLE #removed_backup;
PRINT 'Done.';