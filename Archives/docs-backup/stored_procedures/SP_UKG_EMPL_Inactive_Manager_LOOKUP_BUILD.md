# stage.SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD

Source: HealthTime SQL (STAGE/Archives) — stored procedure to build the inactive-manager lookup used by downstream history and reporting jobs.

Summary: Builds a lookup of inactive managers (by EMPLID / position) for use in hierarchy reconciliation and inactive-manager reporting.

Technical notes:
- Schema: stage
- Pattern: lookup build; idempotent CREATE/ALTER procedure
- Useful for: incremental history, inactive-manager processes

<!-- Collapsed SQL (full source file linked) -->
<details>
<summary>Show SQL</summary>

-- Source: STAGE/Archives (see repository for exact file)

</details>
