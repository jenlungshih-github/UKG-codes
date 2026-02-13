# stage.SP_UKG_EMPLOYEE_DATA_HISTORY_INSERTASBEGIN_SET_NOCOUNT_ON;_DECLARE_@today_DATE_=_CAST

Source: docs/stored_procedures/all_procedures.sql

Link to SQL: sql/stage.SP_UKG_EMPLOYEE_DATA_HISTORY_INSERTASBEGIN_SET_NOCOUNT_ON;_DECLARE_@today_DATE_=_CAST.sql

Detected features:
- uses_hashbytes: True
- uses_merge: False
- uses_select_into: True
- uses_temp_tables: False
- uses_dynamic_sql: False
- uses_transactions: False
- uses_drop_table_if_exists: False

---

```sql
CREATE   PROCEDURE [stage].[SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT]ASBEGIN    SET NOCOUNT ON;    DECLARE @today DATE = CAST(GETDATE() AS DATE);    INSERT INTO [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY]    SELECT *,        HASHBYTES('md5', CONCAT(            EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt        )) AS hash_value,        NULL AS NOTE,        @today AS snapshot_date    FROM [dbo].[UKG_EMPLOYEE_DATA] src    WHERE NOT EXISTS (        SELECT 1    FROM [dbo].[UKG_EMPLOYEE_DATA_WITH_HISTORY] hist    WHERE hist.EMPLID = src.EMPLID        AND hist.hash_value = HASHBYTES('md5', CONCAT(                src.EMPLID, src.DEPTID, src.VC_CODE, src.hr_status, src.empl_Status, src.termination_dt, src.action, src.action_dt            ))    );END
```
