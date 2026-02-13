# stage.SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD

Source: ../HealthTime SQL/STAGE/SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD.sql

Purpose:
Find inactive employee IDs for a given pay period (used in inactive/terminated processing).

Technical details / Version history:
- Parameters: @payenddt DATE
- Uses pay period window (payenddt -13 days) to identify inactive EMPLIDs.

Details — Full SQL (collapsed):
<details>
<summary>Show SQL</summary>

```sql
-- See source file: HealthTime SQL/STAGE/SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD.sql
```

</details>
