# PowerShell script to fetch complete SQL definitions for all 37 stored procedures using sqlcmd

$server = "INFOSDBP06\INFOS06PRD"
$database = "HealthTime"
$basePath = "c:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data\docs\stored_procedures\sql"

# Ensure directory exists
New-Item -ItemType Directory -Force -Path $basePath

# List of all 37 procedures (schema.name) - updated with correct list from database
$procedures = @(
    "dbo.UKG_EMPLOYEE_DATA_BUILD",
    "dbo.UKG_JOBGROUP_BUILD",
    "dbo.UKG_LABOR_CATEGORY_ENTRY_BUILD",
    "dbo.UKG_LABOR_CATEGORY_ENTRY_LIST_and_PROFILE_BUILD",
    "dbo.UKG_LOCATION_BUILD",
    "dbo.UKG_ORG_SETS_AND_EMP_GROUPS_BUILD",
    "dbo.UKG_UCPATH_ACCRUAL_BUILD",
    "hts.UKG_BusinessStructure_UPD",
    "stage.EMPL_DEPT_TRANSFER_build",
    "stage.QA_SP_UKG_EMPLOYEE_DATA_DEBUG",
    "stage.SP_Check_Person_Business_Structure",
    "stage.SP_Check_Update_A",
    "stage.SP_Check_Update_B",
    "stage.SP_CheckByPosition_Health_ODS",
    "stage.SP_CheckByPosition_Manager_LEVEL_Health_ODS",
    "stage.SP_Create_Position_Trace_Analysis",
    "stage.SP_NON_UKG_MANAGER_HISTORY_MERGE",
    "stage.SP_PRE_Check_Update_A",
    "stage.SP_PRE_Check_Update_B",
    "stage.SP_UKG_Accrual_Update_Final_Step",
    "stage.SP_UKG_BusinessStructure_lookup_BUILD",
    "stage.SP_UKG_EMPL_Business_Structure_Lookup_Build",
    "stage.SP_UKG_EMPL_DATA_CleanUp-Step1",
    "stage.SP_UKG_EMPL_DATA_Update_imgr-Step3",
    "stage.SP_UKG_EMPL_DATA_Update_LMS-Step5",
    "stage.SP_UKG_EMPL_Inactive_Manager_Hierarchy_LOOKUP_BUILD-Step2",
    "stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD",
    "stage.SP_UKG_EMPL_STATUS_LOOKUP_BUILD_RETRO_ONLY",
    "stage.SP_UKG_EMPL_Update_Manager_Flag-Step4",
    "stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_INSERT",
    "stage.SP_UKG_EMPLOYEE_DATA_DAILY_INCREMENTAL_HISTORY_UPDATE_PROB_END_DT",
    "stage.SP_UKG_EMPLOYEE_DATA_HISTORY_INSERT",
    "stage.SP_UKG_EMPLOYEE_DATA_RETRO_ONLY_INSERT",
    "stage.SP_UKG_EMPLOYEE_DATA_TERMINATED_BUILD",
    "stage.SP_UKG_EMPLOYEE_DATA_UPDATE_PROB_END_DT",
    "stage.SP_UKG_GET_INACTIVE_EMPLID_BY_PAYPERIOD",
    "stage.SP_UKG_HR_STATUS_LOOKUP_BUILD"
)

foreach ($proc in $procedures) {
    $filePath = Join-Path $basePath "$proc.sql"
    $query = "SET NOCOUNT ON; EXEC sp_helptext '$proc';"
    sqlcmd -S $server -d $database -E -Q $query -o $filePath -h -1
    Write-Host "Fetched $proc to $filePath"
}