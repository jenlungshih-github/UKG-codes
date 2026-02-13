# stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD

Source: HealthTime SQL (STAGE/Archives) — builds employee status lookup used by history and reporting jobs.

Summary: Produces the most-recent status per employee and related fields (EFFDT, EFFSEQ, EMPL_RCD, HIRE_DT) with integrity guards.

Technical notes:
- Schema: stage
- Includes logic to prefer latest hire-date changes and ensures EFFDT >= HIRE_DT.

<details>
<summary>Show SQL</summary>

-- Source: STAGE/Archives (see repository for exact file)

</details>
