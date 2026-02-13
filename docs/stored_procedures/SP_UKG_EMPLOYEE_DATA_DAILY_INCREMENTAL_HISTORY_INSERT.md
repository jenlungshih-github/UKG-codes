# stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT

Source: ../HealthTime SQL/STAGE/SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT-ver3.sql

Purpose:
Template for inserting incremental history rows into the employee history table using hash detection.

Technical details / Version history:
- Uses HASHBYTES MD5 on key columns to populate hash_value for change detection.

Details — Full SQL (collapsed):
<details>
<summary>Show SQL</summary>

```sql
-- See source file: HealthTime SQL/STAGE/SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT-ver3.sql
```

</details>
