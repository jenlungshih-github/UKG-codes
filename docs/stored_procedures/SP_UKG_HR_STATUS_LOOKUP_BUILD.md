# stage.SP_UKG_HR_STATUS_LOOKUP_BUILD

Source: ../HealthTime SQL/STAGE/SP_UKG_HR_STATUS_LOOKUP_BUILD.sql

Purpose:
Builds [stage].[UKG_HR_STATUS_LOOKUP] summarizing employee HR status with prioritization rules and data integrity checks.

Technical details / Version history:
- Includes logic to ensure EFFDT >= HIRE_DT and selects most recent status changes.

Details — Full SQL (collapsed):
<details>
<summary>Show SQL</summary>

```sql
-- See source file: HealthTime SQL/STAGE/SP_UKG_HR_STATUS_LOOKUP_BUILD.sql
```

</details>
