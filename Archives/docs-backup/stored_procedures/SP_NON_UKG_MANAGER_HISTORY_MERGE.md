# stage.SP_NON_UKG_MANAGER_HISTORY_MERGE

Source file: ../HealthTime SQL/STAGE/SP_NON_UKG_MANAGER_HISTORY_MERGE-ver8.sql

## Purpose
Merge Non-UKG Manager data from UKG_EMPLOYEE_DATA_TEMP into NON_UKG_MANAGER_HISTORY table using composite key matching on [Person Number] and [Manager Flag].

## Header / Technical Details
- Created By: GitHub Copilot
- Created Date: 12/03/2025
- Version history: 1.4 (2026-01-28) — updated logic for NON_UKG_MANAGER_FLAG changes and NOTE handling.
- Hashing: HASHBYTES('md5', CONCAT(EMPLID, DEPTID, VC_CODE, hr_status, empl_Status, termination_dt, action, action_dt)) stored in [hash_value]
- Update_DT populated with GETDATE() for inserted/reactivated/deleted rows

## Business Logic Summary
- Inserts new rows from `UKG_EMPLOYEE_DATA_TEMP` where NON_UKG_MANAGER_FLAG='T' or manager flagged rows with BYA exclusion.
- Updates Custom Field 9 = 'T' for all manager records.
- Marks historical rows missing from the source as pending with NOTE='P', sets Employment Status='T', Manager Flag='F', and Update_DT=GETDATE().
- Marks NOTE='P' for rows where source shows NON_UKG_MANAGER_FLAG transitioned from 'T' to 'F' for same EMPLID (unless NOTE='D').
- Reactivation behavior: if source row reappears and matches a deleted row by hash, Update_DT updated and new record inserted.

## Sample run output
When executed, procedure returns a summary with RecordsInserted and RecordsDeleted and shows a sample of recently inserted rows.

## Source SQL
<details>
<summary>Show full SQL</summary>

```sql
-- Source: HealthTime SQL/STAGE/SP_NON_UKG_MANAGER_HISTORY_MERGE-ver8.sql

-- ...existing code...

```

</details>

---
Notes: This file was generated automatically. Create additional pages by extracting other procedure headers from the repository and adding them to `docs/index.md`. 
