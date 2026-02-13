-- Diagnostic: Compare duplicate groups for EMPLID 10473712
-- Identify groups by (EMPLID, hash_value, NOTE) with more than one row
DECLARE @EMPLID VARCHAR(11) = '10473712';

-- build reusable temp table of duplicate groups
IF OBJECT_ID('tempdb..#groups') IS NOT NULL DROP TABLE #groups;
SELECT hash_value, NOTE, COUNT(*) AS cnt
INTO #groups
FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
WHERE EMPLID = @EMPLID
GROUP BY hash_value, NOTE
HAVING COUNT(*) > 1;

SELECT
    g.hash_value,
    g.NOTE,
    g.cnt,
    -- distinct value counts for key columns
    (SELECT COUNT(DISTINCT CAST(position_nbr AS varchar(50)))
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_position_nbr,
    (SELECT COUNT(DISTINCT CAST(EMPL_RCD AS varchar(10)))
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_empl_rcd,
    (SELECT COUNT(DISTINCT termination_dt)
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_termination_dt,
    (SELECT COUNT(DISTINCT action)
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_action,
    (SELECT COUNT(DISTINCT action_dt)
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_action_dt,
    (SELECT COUNT(DISTINCT snapshot_date_TXT)
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_snapshot_date_txt,
    (SELECT COUNT(DISTINCT snapshot_date)
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_snapshot_date,
    (SELECT COUNT(DISTINCT [Home Business Structure Level 1 - Organization])
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY h
    WHERE h.EMPLID = @EMPLID AND h.hash_value = g.hash_value AND h.NOTE = g.NOTE) AS distinct_org_level1
FROM #groups g
ORDER BY cnt DESC;

-- For each duplicate group, show the detailed rows for manual comparison
PRINT '--- Detailed rows for each duplicate group ---';
DECLARE dup_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT hash_value, NOTE
FROM #groups;

DECLARE @hv VARBINARY(8000);
DECLARE @note VARCHAR(5);
OPEN dup_cursor;
FETCH NEXT FROM dup_cursor INTO @hv, @note;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Group: hash_value=' + ISNULL(CONVERT(varchar(100), @hv, 1),'<NULL>') + ' NOTE=' + ISNULL(@note,'<NULL>');
    SELECT ROW_NUMBER() OVER (ORDER BY snapshot_date_TXT DESC) AS rn, *
    FROM dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY
    WHERE EMPLID = @EMPLID AND hash_value = @hv AND NOTE = @note
    ORDER BY snapshot_date_TXT DESC;

    FETCH NEXT FROM dup_cursor INTO @hv, @note;
END
CLOSE dup_cursor;
DEALLOCATE dup_cursor;

-- cleanup
IF OBJECT_ID('tempdb..#groups') IS NOT NULL DROP TABLE #groups;

PRINT 'Done.';