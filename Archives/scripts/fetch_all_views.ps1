$server = "INFOSDBP06\INFOS06PRD"
$database = "HealthTime"
$basePath = "c:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data\docs\stored_procedures\views"
$indexFile = "c:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data\docs\index_VIEW.md"

# Ensure directory exists
New-Item -ItemType Directory -Force -Path $basePath

# Get the list of views
$queryList = "SELECT SCHEMA_NAME(o.schema_id) + '.' + o.name AS view_name FROM sys.objects o WHERE o.type = 'V' AND SCHEMA_NAME(o.schema_id) IN ('dbo','hts','stage') ORDER BY SCHEMA_NAME(o.schema_id), o.name;"
$views = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $queryList -TrustServerCertificate | Select-Object -ExpandProperty view_name

$entries = @()
$counter = 1
foreach ($v in $views) {
    $filePath = Join-Path $basePath ("$v.sql")
    $query = "SET NOCOUNT ON; EXEC sp_helptext '$v';"
    sqlcmd -S $server -d $database -E -Q $query -o $filePath -h -1
    $entries += "$counter. [$v](./stored_procedures/views/$v.sql)"
    $counter++
}

# Inject into index_VIEW.md between markers
$indexContent = Get-Content -Path $indexFile -Raw
$start = '<!-- VIEW_LIST_START -->'
$end = '<!-- VIEW_LIST_END -->'
$replacement = $start + "`n`n" + ($entries -join "`n") + "`n`n" + $end
$newContent = [regex]::Replace($indexContent, [regex]::Escape($start) + '.*?' + [regex]::Escape($end), $replacement, 'Singleline')
Set-Content -Path $indexFile -Value $newContent -Encoding utf8
Write-Host "Fetched $($views.Count) views and updated $indexFile"