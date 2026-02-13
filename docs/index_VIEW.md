<!-- filepath: c:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data\docs\index_VIEW.md -->
# Views Documentation (HealthTime)

This documentation will contain links to the SQL source files for each VIEW in the HealthTime production database. Each link opens the raw SQL definition.

Run `scripts\fetch_all_views.ps1` to fetch all view definitions from HealthTime and populate the list below.

<!-- VIEW_LIST_START -->

1. [dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY-for-Access_V](./stored_procedures/views/dbo.UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY-for-Access_V.sql)
2. [dbo.UKG_EMPLOYEE_DATA_RETRO_ONLY_V](./stored_procedures/views/dbo.UKG_EMPLOYEE_DATA_RETRO_ONLY_V.sql)
3. [dbo.UKG_EMPLOYEE_DATA_V](./stored_procedures/views/dbo.UKG_EMPLOYEE_DATA_V.sql)
4. [dbo.UKG_LABOR_CATEGORY_ENTRY_V](./stored_procedures/views/dbo.UKG_LABOR_CATEGORY_ENTRY_V.sql)
5. [dbo.UKG_LOCATION_V](./stored_procedures/views/dbo.UKG_LOCATION_V.sql)
6. [hts.UKG_BSNonEmployee](./stored_procedures/views/hts.UKG_BSNonEmployee.sql)
7. [hts.UKG_BusinessStructureNoEmployees](./stored_procedures/views/hts.UKG_BusinessStructureNoEmployees.sql)
8. [hts.UKG_differncds](./stored_procedures/views/hts.UKG_differncds.sql)
9. [hts.UKG_FundGroup_ChartString](./stored_procedures/views/hts.UKG_FundGroup_ChartString.sql)
10. [hts.UKG_ODSEntity](./stored_procedures/views/hts.UKG_ODSEntity.sql)
11. [hts.UKG_ODSFinancialUnits](./stored_procedures/views/hts.UKG_ODSFinancialUnits.sql)
12. [hts.UKG_PayrollExport_181_ChartStringCRT](./stored_procedures/views/hts.UKG_PayrollExport_181_ChartStringCRT.sql)
13. [hts.UKG_PayrollExport_618_ChartStringCRT](./stored_procedures/views/hts.UKG_PayrollExport_618_ChartStringCRT.sql)
14. [hts.UKG_ServiceLines_MedicalCenter](./stored_procedures/views/hts.UKG_ServiceLines_MedicalCenter.sql)
15. [hts.UKG_ServiceLines_PHSO](./stored_procedures/views/hts.UKG_ServiceLines_PHSO.sql)
16. [stage.check_6_BS_Missing_V](./stored_procedures/views/stage.check_6_BS_Missing_V.sql)
17. [stage.CURRENT_POSITION_PRI_FIN_UNIT_V](./stored_procedures/views/stage.CURRENT_POSITION_PRI_FIN_UNIT_V.sql)
18. [stage.UKG_ANSOS_V](./stored_procedures/views/stage.UKG_ANSOS_V.sql)
19. [stage.UKG_tsr_differncds_V](./stored_procedures/views/stage.UKG_tsr_differncds_V.sql)

<!-- VIEW_LIST_END -->

Notes:

- The fetch script will save each view as `docs/stored_procedures/views/<schema>.<view_name>.sql` and will inject the enumerated list between the markers above.
- You can re-run the script to refresh definitions and the index.






