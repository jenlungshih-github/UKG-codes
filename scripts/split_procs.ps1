param()

# Splits docs/stored_procedures/all_procedures.sql into individual SQL files and creates per-proc Markdown docs
# Usage: pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\split_procs.ps1

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
$allFile = Join-Path $root '..\docs\stored_procedures\all_procedures.sql' | Resolve-Path -LiteralPath
$allFile = $allFile.Path
$sqlOutDir = Join-Path $root '..\docs\stored_procedures\sql'
$mdOutDir = Join-Path $root '..\docs\stored_procedures'
$siteFile = Join-Path $root '..\docs\site\procs.html'

if (-not (Test-Path $allFile)) {
    Write-Error "Source file not found: $allFile"
    exit 1
}

New-Item -ItemType Directory -Force -Path $sqlOutDir | Out-Null
New-Item -ItemType Directory -Force -Path $mdOutDir | Out-Null

$content = Get-Content -Raw -LiteralPath $allFile

# Regex to capture each procedure block including preceding comments up to the CREATE PROCEDURE
$pattern = '(?is)(?:/\*{0,2}[\s\S]*?\*/\s*)?(?:--[\s\S]*?\r?\n)*?(CREATE\s+PROCEDURE[\s\S]*?)(?=(?:\r?\n\s*CREATE\s+PROCEDURE\s)|\z)'

$procMatches = [regex]::Matches($content, $pattern)

if ($procMatches.Count -eq 0) {
    Write-Host "No CREATE PROCEDURE blocks found. Aborting."
    exit 0
}

$procIndex = 0
$links = @()
foreach ($m in $procMatches) {
    $block = $m.Groups[1].Value.TrimStart()

    # Try to extract the full name token after CREATE PROCEDURE
    if ($block -match '(?i)CREATE\s+PROCEDURE\s+([^\r\n\(]+)') {
        $rawName = $Matches[1].Value.Trim()
        # sanitize name token: remove brackets and double quotes and whitespace
        $sanName = $rawName -replace '\[','' -replace '\]','' -replace '"','' -replace '\s+',''
        # replace spaces and commas
        $sanName = $sanName -replace '[,\s]',''
    } else {
        # fallback name
        $procIndex++
        $sanName = "proc_$procIndex"
    }

    # if name contains schema.proc keep it, else prefix with unknown
    $fileBase = $sanName
    $sqlPath = Join-Path $sqlOutDir ($fileBase + '.sql')
    $mdPath = Join-Path $mdOutDir ($fileBase + '.md')

    # write SQL file
    Set-Content -LiteralPath $sqlPath -Value $block -Encoding UTF8

    # detect tech flags
    $upper = $block.ToUpper()
    $flags = @{}
    $flags['uses_hashbytes'] = $upper.Contains('HASHBYTES')
    $flags['uses_merge'] = $upper.Contains('\bMERGE\b')
    $flags['uses_select_into'] = $upper.Contains('SELECT') -and $upper.Contains('INTO')
    $flags['uses_temp_tables'] = $upper.Contains('DROP TABLE IF EXISTS') -or $upper.Contains('INTO #') -or $upper.Contains('\b#')
    $flags['uses_dynamic_sql'] = $upper.Contains('SP_EXECUTESQL') -or $upper.Contains('EXEC(') -or $upper.Contains('EXEC @')
    $flags['uses_transactions'] = $upper.Contains('BEGIN TRAN') -or $upper.Contains('COMMIT TRAN') -or $upper.Contains('ROLLBACK TRAN')
    $flags['uses_drop_table_if_exists'] = $upper.Contains('DROP TABLE IF EXISTS')

    # create markdown
    $md = @()
    $md += "# $fileBase"
    $md += ""
    $md += "Source: docs/stored_procedures/all_procedures.sql"
    $md += ""
    $md += "Link to SQL: sql/$($fileBase).sql"
    $md += ""
    $md += "Detected features:"
    foreach ($k in $flags.Keys) {
        $md += "- $k : $($flags[$k])"
    }
    $md += ""
    $md += "---"
    $md += ""
    $md += "```sql"
    # include only first 300 lines as preview to avoid huge md files
    $lines = $block -split "\r?\n"
    $preview = $lines[0..([Math]::Min($lines.Count-1, 300))] -join [Environment]::NewLine
    $md += $preview
    $md += "```"

    Set-Content -LiteralPath $mdPath -Value ($md -join [Environment]::NewLine) -Encoding UTF8

    # prepare site link entry
    $extra = ''
    if ($flags['uses_hashbytes']) { $extra += 'HASHBYTES ' }
    if ($flags['uses_merge']) { $extra += 'MERGE ' }
    $linkHtml = "<li><a href='../stored_procedures/sql/$($fileBase).sql'>$fileBase</a> - $extra</li>"
    $links += $linkHtml

    $procIndex++
}

# Append links to procs.html between markers
if (Test-Path $siteFile) {
    $siteContent = Get-Content -Raw -LiteralPath $siteFile
    $startMarker = '<!-- PROC_LIST_START -->'
    $endMarker = '<!-- PROC_LIST_END -->'
    if ($siteContent -match [regex]::Escape($startMarker) -and $siteContent -match [regex]::Escape($endMarker)) {
        $newList = $startMarker + [Environment]::NewLine + '<ul>' + [Environment]::NewLine + ($links -join [Environment]::NewLine) + [Environment]::NewLine + '</ul>' + [Environment]::NewLine + $endMarker
        # above replacement escapes markup, so instead perform manual replacement
        $before = $siteContent.Split($startMarker)[0]
        $after = $siteContent.Split($endMarker)[1]
        $siteNew = $before + $startMarker + [Environment]::NewLine + '<ul>' + [Environment]::NewLine + ($links -join [Environment]::NewLine) + [Environment]::NewLine + '</ul>' + [Environment]::NewLine + $endMarker + $after
        Set-Content -LiteralPath $siteFile -Value $siteNew -Encoding UTF8
    }
}

Write-Host "Processed $procIndex procedures. SQL files are in: $sqlOutDir, Markdown in: $mdOutDir"

exit 0
