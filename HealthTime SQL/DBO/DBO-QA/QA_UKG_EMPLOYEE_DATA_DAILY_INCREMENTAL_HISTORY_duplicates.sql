-- QA: Investigate duplicate inserts for stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT
-- Focus EMPLID: 10859360
-- Run this in HealthTime DB to inspect history rows, duplicates, and compare against current source hash

DECLARE @EMPLID VARCHAR(11) = '10859360';
DECLARE @now DATETIME = GETDATE();

PRINT '1) All history rows for EMPLID (ordered by snapshot_date)';
SELECT
    ROW_NUMBER() OVER (ORDER BY snapshot_date) AS rn,
    EMPLID,
    position_nbr,
    NOTE,
    snapshot_date_TXT,
    snapshot_date,
    hash_value,
    termination_dt,
    action,
    action_dt,
    [User Account Name],
    [Home Business Structure Level 1 - Organization]
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
ORDER BY snapshot_date ASC;

PRINT '2) Counts by hash_value and NOTE';
SELECT
    CASE WHEN hash_value IS NULL THEN '<NULL>' ELSE CONVERT(varchar(100), hash_value, 1) END AS hash_value_text,
    NOTE,
    COUNT(*) AS occurrences,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
GROUP BY hash_value, NOTE
ORDER BY occurrences DESC, last_seen DESC;

PRINT '3) Hash values that appear more than once';
SELECT
    hash_value,
    COUNT(*) AS cnt,
    STRING_AGG(CONVERT(varchar(30), snapshot_date, 121), ', ') WITHIN GROUP (ORDER BY snapshot_date) AS snapshot_dates
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
GROUP BY hash_value
HAVING COUNT(*) > 1;

PRINT '4) Per-snapshot_date insert counts and NOTES';
SELECT
    snapshot_date_TXT,
    snapshot_date,
    NOTE,
    COUNT(*) AS cnt
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
GROUP BY snapshot_date_TXT, snapshot_date, NOTE
ORDER BY snapshot_date DESC, NOTE;

PRINT '5) Any duplicate rows on same snapshot_date with identical hash_value';
SELECT
    snapshot_date_TXT,
    snapshot_date,
    hash_value,
    COUNT(*) AS dup_count
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
GROUP BY snapshot_date_TXT, snapshot_date, hash_value
HAVING COUNT(*) > 1;

PRINT '6) Latest history row and computed current source hash comparison';
-- Latest history row
SELECT TOP 1
    EMPLID,
    position_nbr,
    hash_value AS hist_hash,
    NOTE,
    snapshot_date
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
ORDER BY snapshot_date DESC;

-- Current source row and computed hash (use same concat fields as SP)
SELECT
    src.EMPLID,
    src.position_nbr,
    src.DEPTID,
    src.VC_CODE,
    src.hr_status,
    src.empl_Status,
    src.termination_dt,
    src.action,
    src.action_dt,
    HASHBYTES('md5', CONCAT(src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt)) AS computed_hash
FROM [dbo].[UKG_EMPLOYEE_DATA] src
WHERE src.EMPLID = @EMPLID;

PRINT '7) Check prior deletion entries with same hash (if applicable)';
SELECT
    hash_value,
    NOTE,
    COUNT(*) AS cnt,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EMPLID = @EMPLID
    AND NOTE = 'D'
GROUP BY hash_value, NOTE
ORDER BY cnt DESC;

PRINT '8) Rows inserted on the same day as the latest snapshot (help find repeated runs)';
;
WITH
    latest
    AS
    (
        SELECT TOP 1
            snapshot_date AS latest_snapshot
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        WHERE EMPLID = @EMPLID
        ORDER BY snapshot_date DESC
    )
SELECT h.*
FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] h
CROSS JOIN latest l
WHERE h.EMPLID = @EMPLID
    AND CAST(h.snapshot_date AS DATE) = CAST(l.latest_snapshot AS DATE)
ORDER BY h.snapshot_date, h.NOTE;

PRINT '9) Quick suggestions: If duplicates exist with same hash and same NOTE and snapshot_date, check if procedure was run multiple times or truncation logic failed.';

-- End of QA script
