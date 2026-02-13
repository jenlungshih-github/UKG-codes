-- Check duplicates for EMPLID = 10473712 in UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
DECLARE @EMPLID VARCHAR(11) = '10473712';

PRINT 'All history rows for EMPLID (ordered by snapshot_date):';
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
    action_dt
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
ORDER BY snapshot_date ASC;

PRINT 'Counts by hash_value and NOTE:';
SELECT
    CASE WHEN hash_value IS NULL THEN '<NULL>' ELSE CONVERT(varchar(100), hash_value, 1) END AS hash_value_text,
    NOTE,
    COUNT(*) AS occurrences,
    MIN(snapshot_date) AS first_seen,
    MAX(snapshot_date) AS last_seen
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY hash_value, NOTE
ORDER BY occurrences DESC, last_seen DESC;

PRINT 'Any duplicate rows on same snapshot_date with identical hash_value:';
SELECT
    snapshot_date_TXT,
    snapshot_date,
    hash_value,
    COUNT(*) AS dup_count
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY snapshot_date_TXT, snapshot_date, hash_value
HAVING COUNT(*) > 1;

PRINT 'Summary per snapshot_date and NOTE:';
SELECT snapshot_date_TXT, NOTE, COUNT(*) AS cnt
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY snapshot_date_TXT, NOTE
ORDER BY snapshot_date_TXT DESC;

PRINT 'End of check.';