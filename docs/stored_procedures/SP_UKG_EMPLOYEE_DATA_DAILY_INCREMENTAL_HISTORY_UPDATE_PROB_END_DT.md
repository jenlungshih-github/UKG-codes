# stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT

Source: ../HealthTime SQL/STAGE/SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT-ver2.sql

Purpose:
Update probation end date into Custom Date 1 for incremental history rows, with guard to avoid reapplying when NOTE already contains probation message.

Technical details / Version history:
- Updates Custom Date 1 = DATEADD(day,1,probation_end_dt)
- Skips rows where NOTE contains probation update message

Details — Full SQL (collapsed):
<details>
<summary>Show SQL</summary>

```sql
-- See source file: HealthTime SQL/STAGE/SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT-ver2.sql
```

</details>
