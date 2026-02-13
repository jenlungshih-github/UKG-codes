-- CTE to identify records with multiple NOTE types and containing NOTE='D'
WITH
    EmployeesWithMultipleNotesAndDeletes
    AS
    (
        SELECT emplid, NOTE, snapshot_date
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        WHERE emplid IN (
        SELECT emplid
        FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
        GROUP BY emplid
        HAVING COUNT(DISTINCT NOTE) > 1
            AND 'D' IN (SELECT DISTINCT NOTE
            FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY] sub
            WHERE sub.emplid = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].emplid)
    )
    )

-- Delete records with snapshot_date on or after 12/2/2025, keeping only older records
DELETE FROM [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
WHERE EXISTS (
    SELECT 1
    FROM EmployeesWithMultipleNotesAndDeletes cte
    WHERE cte.emplid = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].emplid
        AND cte.NOTE = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].NOTE
        AND cte.snapshot_date = [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY].snapshot_date
)
    AND snapshot_date >= '2025-12-02';