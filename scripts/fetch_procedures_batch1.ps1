# PowerShell script to fetch and save stored procedure definitions in small batches

$server = "INFOSDBP06\INFOS06PRD"
$database = "HealthTime"
$schema = "stage"
$basePath = "c:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data\docs\stored_procedures\sql"

# Create directory if not exists
New-Item -ItemType Directory -Force -Path $basePath

# List of procedures (first batch of 5)
$procedures = @(
    "SP_CheckByEmplid",
    "SP_CheckByPosition_Health_ODS",
    "SP_CheckByPosition_Manager_LEVEL_Health_ODS",
    "SP_Check_Person_Business_Structure",
    "SP_Create_Position_Trace_Analysis"
)

foreach ($proc in $procedures) {
    $query = "SELECT m.definition FROM sys.sql_modules m JOIN sys.objects o ON m.object_id = o.object_id WHERE o.name = '$proc' AND SCHEMA_NAME(o.schema_id) = '$schema';"
    $result = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $query
    $definition = $result.definition
    $filePath = Join-Path $basePath "stage.$proc.sql"
    $definition | Out-File -FilePath $filePath -Encoding utf8
    Write-Host "Saved $proc to $filePath"
}