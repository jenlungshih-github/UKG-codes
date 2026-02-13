# Stored Procedures Documentation

This documentation contains links to the SQL source files for each stored procedure in the repository. Each link opens the raw SQL definition.

1. [dbo.UKG_EMPLOYEE_DATA_BUILD](./stored_procedures/sql/dbo.UKG_EMPLOYEE_DATA_BUILD.sql) — Main employee data build.
2. [stage.SP_CheckByEmplid](./stored_procedures/sql/stage.SP_CheckByEmplid.sql) — Employee check by EMPLID.
3. [stage.SP_CheckByPosition_Health_ODS](./stored_procedures/sql/stage.SP_CheckByPosition_Health_ODS.sql) — Position-level QA checks.
4. [stage.SP_CheckByPosition_Manager_LEVEL_Health_ODS](./stored_procedures/sql/stage.SP_CheckByPosition_Manager_LEVEL_Health_ODS.sql) — Manager-level QA checks.
5. [stage.SP_Check_Person_Business_Structure](./stored_procedures/sql/stage.SP_Check_Person_Business_Structure.sql) — Business-structure QA checks.
6. [stage.SP_Create_Position_Trace_Analysis](./stored_procedures/sql/stage.SP_Create_Position_Trace_Analysis.sql) — Position trace analysis for inactive managers.
7. [stage.SP_NON_UKG_MANAGER_HISTORY_MERGE](./stored_procedures/sql/stage.SP_NON_UKG_MANAGER_HISTORY_MERGE.sql) — Merge Non-UKG Manager history.
8. [stage.SP_NON_UKG_MANAGER_LOG_MERGE](./stored_procedures/sql/stage.SP_NON_UKG_MANAGER_LOG_MERGE.sql) — Non-UKG manager log/merge.
9. [stage.SP_UKG_BusinessStructure_lookup_BUILD](./stored_procedures/sql/stage.SP_UKG_BusinessStructure_lookup_BUILD.sql) — Business-structure lookup build.
10. [stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT.sql) — Incremental history insert template.
11. [stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT-ver2](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT-ver2.sql) — Alternate/archived variant.
12. [stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT.sql) — Update probation end date into Custom Date 1.
13. [stage.SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT.sql) — Historical employee data insert.
14. [stage.SP_UKG_EMPLOYEE_DATA_RETRO_ONLY_INSERT](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_RETRO_ONLY_INSERT.sql) — Retro-only insert routine.
15. [stage.SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD](./stored_procedures/sql/stage.SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD.sql) — Terminated employees build.
16. [stage.SP_UKG_EMPL_Business_Structure_Lookup_Build](./stored_procedures/sql/stage.SP_UKG_EMPL_Business_Structure_Lookup_Build.sql) — Build for employee business structure lookup.
17. [stage.SP_UKG_EMPL_DATA_CleanUp-Step1](./stored_procedures/sql/stage.SP_UKG_EMPL_DATA_CleanUp-Step1.sql) — Initial cleanup step for employee data.
18. [stage.SP_UKG_EMPL_DATA_Update_imgr-Step3](./stored_procedures/sql/stage.SP_UKG_EMPL_DATA_Update_imgr-Step3.sql) — IMGR update step 3.
19. [stage.SP_UKG_EMPL_DATA_Update_LMS-Step5](./stored_procedures/sql/stage.SP_UKG_EMPL_DATA_Update_LMS-Step5.sql) — LMS update step 5.
20. [stage.SP_UKG_EMPL_HIERARCHY_POSN_LOOKUP_BUILD](./stored_procedures/sql/stage.SP_UKG_EMPL_HIERARCHY_POSN_LOOKUP_BUILD.sql) — Position hierarchy lookup build.
21. [stage.SP_UKG_EMPL_Inactive_Manager_BUILD-step1](./stored_procedures/sql/stage.SP_UKG_EMPL_Inactive_Manager_BUILD-step1.sql) — Inactive manager build step 1.
22. [stage.SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD](./stored_procedures/sql/stage.SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD.sql) — Inactive manager hierarchy lookup.
23. [stage.SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2](./stored_procedures/sql/stage.SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2.sql) — Secondary hierarchy build (step 2).
24. [stage.SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD](./stored_procedures/sql/stage.SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD.sql) — Inactive manager lookup build.
25. [stage.SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD-Ver2](./stored_procedures/sql/stage.SP_UKG_EMPL_Inactive_Manager_LOOKUP_BUILD-Ver2.sql) — Archive variant of inactive-manager lookup.
26. [stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD](./stored_procedures/sql/stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD.sql) — Builds employee status lookup used by history.
27. [stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD_RETRO_ONLY](./stored_procedures/sql/stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD_RETRO_ONLY.sql) — Retro-only status lookup build.
28. [stage.SP_UKG_EMPL_Update_Manager_Flag-Step4](./stored_procedures/sql/stage.SP_UKG_EMPL_Update_Manager_Flag-Step4.sql) — Update manager flag (step 4).
29. [stage.SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD](./stored_procedures/sql/stage.SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD.sql) — Get inactive emplids by pay period.
30. [stage.SP_UKG_HR_STATUS_LOOKUP_BUILD](./stored_procedures/sql/stage.SP_UKG_HR_STATUS_LOOKUP_BUILD.sql) — Build HR status lookup.
31. [stage.SP_UKG_Position_Reports_Analysis_Level_3](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_3.sql) — Position reports analysis (Level 3).
32. [stage.SP_UKG_Position_Reports_Analysis_Level_UP](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_UP.sql) — Position reports analysis (Level UP).
33. [stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver2](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver2.sql) — Variant of position reports analysis.
34. [stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver3](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver3.sql) — Archived variant (ver3) of position reports analysis.
35. [stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver4](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver4.sql) — Archived variant (ver4) of position reports analysis.
36. [stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver5](./stored_procedures/sql/stage.SP_UKG_Position_Reports_Analysis_Level_UP-ver5.sql) — Archived variant (ver5) of position reports analysis.
37. [stage.SP_UKG_UCPATH_ACCRUAL_per_ASOFDATE](./stored_procedures/sql/stage.SP_UKG_UCPATH_ACCRUAL_per_ASOFDATE.sql) — UCPATH accrual per as-of date.
38. [stage.SP_UKG_UCPATH_ACCRUAL_BUILD](./stored_procedures/sql/stage.SP_UKG_UCPATH_ACCRUAL_BUILD.sql) — Build UCPATH accruals.
