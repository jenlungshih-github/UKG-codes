-- Remove duplicate records for a list of EMPLIDs in dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
-- Keeps only the oldest snapshot_date_TXT for each (EMPLID, hash_value, NOTE)
-- Edit the @EMPS insert list below to target specific EMPLIDs.

SET NOCOUNT ON;

DECLARE @EMPS TABLE (EMPLID VARCHAR(11));
-- Example: add EMPLIDs to process
INSERT INTO @EMPS
    (EMPLID)
VALUES
    ('10473712'),
    -- example
    ('10859360');
-- example

-- Summary: count potential duplicates
;WITH
    cte_check
    AS
    (
        SELECT EMPLID, hash_value, NOTE, COUNT(*) AS cnt
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
        WHERE h.EMPLID IN (SELECT EMPLID
        FROM @EMPS)
        GROUP BY EMPLID, hash_value, NOTE
        HAVING COUNT(*) > 1
    )
SELECT COUNT(*) AS duplicate_groups_found
FROM cte_check;

BEGIN TRY
    BEGIN TRANSACTION;

    -- backup duplicates into temp table
    IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

    ;WITH
    cte
    AS
    (
        SELECT h.*,
            ROW_NUMBER() OVER (PARTITION BY h.EMPLID, h.hash_value ORDER BY h.snapshot_date_TXT ASC, h.snapshot_date ASC) AS rn
        FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
        WHERE h.EMPLID IN (SELECT EMPLID
        FROM @EMPS)
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
    -- delete duplicates, keeping the oldest snapshot_date_TXT
    ;WITH
        cte_del
        AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY EMPLID, hash_value, NOTE ORDER BY snapshot_date_TXT ASC, snapshot_date ASC) AS rn
            FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
            WHERE EMPLID IN (SELECT EMPLID
            FROM @EMPS)
        )
        DELETE FROM cte_del
        WHERE rn > 1;

    PRINT 'Deleted rows: ' + CAST(@@ROWCOUNT AS VARCHAR(20));

    -- show sample of removed rows
    PRINT 'Sample of removed duplicate rows (from temp backup):';
    SELECT TOP 200
        EMPLID, position_nbr, NOTE, snapshot_date_TXT, snapshot_date, hash_value
    FROM #dups_backup
    ORDER BY EMPLID, snapshot_date;
END
    ELSE
    BEGIN
    PRINT 'No duplicate rows found for provided EMPLIDs.';
END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrSev INT = ERROR_SEVERITY();
    DECLARE @ErrState INT = ERROR_STATE();
    RAISERROR(@ErrMsg, @ErrSev, @ErrState);
END CATCH;

-- cleanup
IF OBJECT_ID('tempdb..#dups_backup') IS NOT NULL DROP TABLE #dups_backup;

PRINT 'Done.';