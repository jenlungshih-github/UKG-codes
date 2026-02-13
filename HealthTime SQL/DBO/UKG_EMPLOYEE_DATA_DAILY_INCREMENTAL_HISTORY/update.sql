UPDATE [dbo].[UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY]
SET snapshot_date_TXT = CONVERT(varchar(10), snapshot_date, 23)
WHERE snapshot_date IS NOT NULL
    AND (snapshot_date_TXT IS NULL OR snapshot_date_TXT <> CONVERT(varchar(10), snapshot_date, 23));