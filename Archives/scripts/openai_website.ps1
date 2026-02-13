# PowerShell script to generate a static HTML website from index.md and SQL files
# Run this script to create a browseable website in the docs/site folder

# Configuration Paths
$basePath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$docsDir = Join-Path $basePath "docs"
$indexMdPath = Join-Path $docsDir "index.md"
$sqlSourceDir = Join-Path $docsDir "stored_procedures\sql"
$mdDocsDir = Join-Path $docsDir "stored_procedures"
$siteDir = Join-Path $docsDir "site"

# Ensure output directory exists
if (-not (Test-Path $siteDir)) {
    New-Item -ItemType Directory -Force -Path $siteDir | Out-Null
    Write-Host "Created directory: $siteDir"
}

function Escape-Html([string]$s) {
    if ($null -eq $s) { return "" }
    return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;' -replace "'",'&#39;')
}

function Get-MdSummary([string]$path) {
    if (-not (Test-Path $path)) { return $null }
    $raw = Get-Content $path -Raw
    if (-not $raw) { return $null }

    $blocks = $raw -split "(\r?\n){2,}"
    foreach ($b in $blocks) {
        $t = ($b -replace "\r?\n", " ").Trim()
        if (-not $t) { continue }
        if ($t -match '^#') { continue }
        if ($t -match '^```') { continue }
        return $t
    }
    return $null
}

Write-Host "Reading $indexMdPath..."
$indexMdContent = (Get-Content $indexMdPath -Raw) -replace '—','-'

# Regex to parse lines like: 1. [Name](./path) - Description
$regex = '\[(?<name>.*?)\]\(\./stored_procedures/sql/(?<file>.*?)\)\s+-\s+(?<desc>.*)'
$matches = [regex]::Matches($indexMdContent, $regex)

$descByName = @{}
foreach ($match in $matches) {
    $procName = $match.Groups["name"].Value
    $description = $match.Groups["desc"].Value
    if ($procName) {
        $descByName[$procName] = $description
    }
}

$sqlFiles = Get-ChildItem -File $sqlSourceDir -Filter *.sql | Sort-Object Name

$items = @()
foreach ($file in $sqlFiles) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $schema = ($name -split '\.')[0]
    $desc = $descByName[$name]

    $sqlContent = Get-Content $file.FullName -Raw
    $sqlContent = $sqlContent.TrimEnd()

    $mdPath = Join-Path $mdDocsDir "$name.md"
    $mdSummary = Get-MdSummary $mdPath

    $uses_hashbytes = $sqlContent -match 'HASHBYTES\s*\('
    $uses_merge = $sqlContent -match '\bMERGE\b'
    $uses_select_into = ($sqlContent -match 'SELECT\s+\*') -and ($sqlContent -match '\bINTO\b')
    $uses_temp_tables = $sqlContent -match 'CREATE\s+TABLE|DROP\s+TABLE\s+IF\s+EXISTS|#\w+'
    $uses_dynamic_sql = $sqlContent -match 'sp_executesql|EXEC\s+\(@|EXEC\s+\('
    $uses_transactions = $sqlContent -match 'BEGIN\s+TRANSACTION|BEGIN\s+TRY|COMMIT\s+TRANSACTION|ROLLBACK\s+TRANSACTION'
    $uses_drop_table_if_exists = $sqlContent -match 'DROP\s+TABLE\s+IF\s+EXISTS'

    $tags = @()
    if ($uses_hashbytes) { $tags += 'hashbytes' }
    if ($uses_merge) { $tags += 'merge' }
    if ($uses_select_into) { $tags += 'select-into' }
    if ($uses_temp_tables) { $tags += 'temp-tables' }
    if ($uses_dynamic_sql) { $tags += 'dynamic-sql' }
    if ($uses_transactions) { $tags += 'transactions' }
    if ($uses_drop_table_if_exists) { $tags += 'drop-table-if-exists' }

    $items += [pscustomobject]@{
        Name = $name
        Schema = $schema
        Desc = $desc
        MdSummary = $mdSummary
        Sql = $sqlContent
        Tags = $tags
    }
}

# Build concatenated SQL file for download
$allSqlPath = Join-Path $siteDir "all_procedures.sql"
$allSqlBuilder = New-Object System.Text.StringBuilder
foreach ($item in $items) {
    $null = $allSqlBuilder.AppendLine(("-- ===== {0} =====" -f $item.Name))
    $null = $allSqlBuilder.AppendLine($item.Sql)
    $null = $allSqlBuilder.AppendLine("")
}
$allSqlBuilder.ToString() | Out-File -FilePath $allSqlPath -Encoding utf8
Write-Host "Generated all_procedures.sql"

$schemaGroups = $items | Group-Object Schema | Sort-Object Name
$total = $items.Count
$generated = (Get-Date -Format "yyyy-MM-dd HH:mm")

$sidebarLinks = New-Object System.Text.StringBuilder
$null = $sidebarLinks.AppendLine('<a class="side-link" href="#top">Top</a>')
foreach ($g in $schemaGroups) {
    $schemaId = "schema-" + ($g.Name -replace '[^a-zA-Z0-9_-]', '-')
    $null = $sidebarLinks.AppendLine(('<a class="side-link" href="#{0}">{1} ({2})</a>' -f $schemaId, (Escape-Html $g.Name), $g.Count))
}

$sections = New-Object System.Text.StringBuilder
foreach ($g in $schemaGroups) {
    $schemaName = $g.Name
    $schemaId = "schema-" + ($schemaName -replace '[^a-zA-Z0-9_-]', '-')
    $null = $sections.AppendLine(('<section class="schema-section" id="{0}">' -f $schemaId))
    $null = $sections.AppendLine(('<h2>{0}</h2>' -f (Escape-Html $schemaName)))

    foreach ($item in $g.Group) {
        $id = ($item.Name -replace '[^a-zA-Z0-9_-]', '-')
        $nameEsc = Escape-Html $item.Name
        $descEsc = Escape-Html $item.Desc
        $schemaEsc = Escape-Html $item.Schema
        $summaryEsc = Escape-Html $item.MdSummary
        $sqlEsc = Escape-Html $item.Sql
        $tagsStr = ($item.Tags -join ',')
        $tagBadges = if ($item.Tags.Count -gt 0) { ($item.Tags | ForEach-Object { ('<span class="tag">{0}</span>' -f $_) }) -join '' } else { '<span class="tag muted">none</span>' }

        $null = $sections.AppendLine(('<article class="card" data-name="{0}" data-desc="{1}" data-schema="{2}" data-tags="{3}">' -f $nameEsc, $descEsc, $schemaEsc, $tagsStr))
        $null = $sections.AppendLine('  <div class="card-head">')
        $null = $sections.AppendLine('    <div>')
        $null = $sections.AppendLine(('      <h3 id="{0}">{1}</h3>' -f $id, $nameEsc))
        if ($descEsc) { $null = $sections.AppendLine(('      <p class="desc">{0}</p>' -f $descEsc)) }
        if ($summaryEsc) { $null = $sections.AppendLine(('      <div class="summary"><strong>Summary:</strong> {0}</div>' -f $summaryEsc)) }
        $null = $sections.AppendLine('    </div>')
        $null = $sections.AppendLine('    <div class="actions">')
        $null = $sections.AppendLine(('      <a class="link" href="../stored_procedures/sql/{0}.sql" target="_blank" rel="noopener">Open SQL</a>' -f $nameEsc))
        $null = $sections.AppendLine(('      <button class="copy" data-copy="{0}">Copy SQL</button>' -f $id))
        $null = $sections.AppendLine('    </div>')
        $null = $sections.AppendLine('  </div>')
        $null = $sections.AppendLine(('  <div class="meta"><span class="schema">{0}</span>{1}</div>' -f $schemaEsc, $tagBadges))
        $null = $sections.AppendLine('  <details>')
        $null = $sections.AppendLine('    <summary>View SQL</summary>')
        $null = $sections.AppendLine(('    <pre id="sql-{0}"><code>{1}</code></pre>' -f $id, $sqlEsc))
        $null = $sections.AppendLine('  </details>')
        $null = $sections.AppendLine('</article>')
    }

    $null = $sections.AppendLine('</section>')
}

$template = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Stored Procedures — Project TSR-UKG</title>
  <style>
    :root {
      --bg-1: #fff7ed;
      --bg-2: #ecfeff;
      --bg-3: #fef3c7;
      --ink: #102a43;
      --muted: #627d98;
      --accent: #0f766e;
      --accent-2: #d97706;
      --card: #ffffff;
      --shadow: 0 18px 50px rgba(2, 6, 23, 0.12);
      --mono: "JetBrains Mono", "Consolas", monospace;
      --sans: "Space Grotesk", "Segoe UI", "Helvetica Neue", sans-serif;
    }

    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: var(--sans);
      color: var(--ink);
      background:
        radial-gradient(circle at 15% 10%, var(--bg-3) 0%, transparent 45%),
        radial-gradient(circle at 85% 0%, #d1fae5 0%, transparent 40%),
        linear-gradient(120deg, var(--bg-1), var(--bg-2));
      min-height: 100vh;
    }
    header {
      padding: 40px 24px 16px;
      max-width: 1280px;
      margin: 0 auto;
    }
    h1 {
      font-size: clamp(28px, 4vw, 46px);
      margin: 0 0 8px 0;
      letter-spacing: -0.02em;
    }
    .subtitle {
      color: var(--muted);
      margin: 0 0 16px 0;
      font-size: 1.05rem;
    }
    .meta-row {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
      color: var(--muted);
      font-size: 0.95rem;
    }
    .meta-row strong { color: var(--ink); }

    .controls {
      max-width: 1280px;
      margin: 0 auto;
      padding: 0 24px 24px;
      display: grid;
      gap: 16px;
    }

    .search {
      display: grid;
      gap: 10px;
      padding: 16px;
      background: rgba(255,255,255,0.8);
      border-radius: 14px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(6px);
    }
    .search input {
      width: 100%;
      padding: 12px 14px;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      font-size: 1rem;
    }

    .tag-filters { display: flex; flex-wrap: wrap; gap: 10px; }
    .tag-filters label { font-size: 0.9rem; color: var(--muted); }

    .download {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--accent);
      color: #fff;
      padding: 10px 14px;
      border-radius: 10px;
      text-decoration: none;
      font-weight: 600;
      width: fit-content;
    }

    .layout {
      max-width: 1280px;
      margin: 0 auto;
      padding: 0 24px 60px;
      display: grid;
      grid-template-columns: 220px 1fr;
      gap: 20px;
      align-items: start;
    }

    aside {
      position: sticky;
      top: 20px;
      background: rgba(255,255,255,0.85);
      border-radius: 14px;
      padding: 14px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(6px);
    }
    .side-title { font-weight: 700; margin-bottom: 8px; }
    .side-link {
      display: block;
      padding: 6px 8px;
      color: var(--accent);
      text-decoration: none;
      border-radius: 8px;
      font-size: 0.95rem;
    }
    .side-link:hover { background: #ecfdf5; }

    main {
      display: grid;
      gap: 26px;
    }

    .schema-section h2 { margin: 0 0 12px; color: #0f172a; }

    .card {
      background: var(--card);
      border-radius: 16px;
      padding: 18px;
      box-shadow: var(--shadow);
      border: 1px solid rgba(15, 118, 110, 0.08);
    }
    .card + .card { margin-top: 16px; }
    .card-head { display: flex; justify-content: space-between; gap: 16px; flex-wrap: wrap; }
    .card h3 { margin: 0 0 6px; font-size: 1.2rem; }
    .desc { margin: 0 0 6px; color: var(--muted); }
    .summary { margin: 0; color: #334e68; font-size: 0.95rem; }
    .actions { display: flex; gap: 8px; align-items: center; }
    .link {
      text-decoration: none;
      color: var(--accent);
      font-weight: 600;
    }
    .copy {
      border: none;
      background: var(--accent-2);
      color: white;
      padding: 8px 10px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 0.85rem;
    }
    .meta { margin-top: 10px; display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
    .schema {
      background: #eff6ff;
      color: #1e40af;
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 0.85rem;
      font-weight: 600;
    }
    .tag {
      background: #fef3c7;
      color: #92400e;
      padding: 4px 8px;
      border-radius: 999px;
      font-size: 0.8rem;
    }
    .tag.muted { background: #f1f5f9; color: #64748b; }

    details { margin-top: 12px; }
    summary { cursor: pointer; font-weight: 600; color: var(--accent); }
    pre {
      margin-top: 10px;
      padding: 14px;
      border-radius: 12px;
      background: #0b1220;
      color: #e2e8f0;
      font-family: var(--mono);
      font-size: 0.85rem;
      overflow: auto;
      max-height: 480px;
    }

    .empty {
      display: none;
      text-align: center;
      color: var(--muted);
      padding: 30px;
    }

    @media (max-width: 900px) {
      .layout { grid-template-columns: 1fr; }
      aside { position: relative; }
    }
  </style>
</head>
<body id="top">
  <header>
    <h1>Stored Procedures Documentation</h1>
    <p class="subtitle">SQL sources and quick metadata for the UKG/HealthTime pipeline.</p>
    <div class="meta-row">
      <span><strong>Total procedures:</strong> __TOTAL__</span>
      <span><strong>Generated:</strong> __GENERATED__</span>
      <span><strong>Source:</strong> docs/index.md + docs/stored_procedures/sql</span>
    </div>
  </header>

  <section class="controls">
    <div class="search">
      <input id="search" type="search" placeholder="Search by name, description, or tag…" />
      <div class="tag-filters">
        <label><input type="checkbox" value="merge" /> MERGE</label>
        <label><input type="checkbox" value="hashbytes" /> HASHBYTES</label>
        <label><input type="checkbox" value="select-into" /> SELECT INTO</label>
        <label><input type="checkbox" value="temp-tables" /> Temp tables</label>
        <label><input type="checkbox" value="dynamic-sql" /> Dynamic SQL</label>
        <label><input type="checkbox" value="transactions" /> Transactions</label>
        <label><input type="checkbox" value="drop-table-if-exists" /> Drop table if exists</label>
      </div>
      <a class="download" href="all_procedures.sql" download>Download all SQL</a>
    </div>
  </section>

  <div class="layout">
    <aside>
      <div class="side-title">Schemas</div>
      __SIDEBAR_LINKS__
    </aside>

    <main id="cards">
      __SECTIONS__
    </main>
  </div>

  <div id="empty" class="empty">No procedures match the current filters.</div>

  <script>
    const cards = Array.from(document.querySelectorAll('.card'));
    const search = document.getElementById('search');
    const checks = Array.from(document.querySelectorAll('.tag-filters input'));
    const empty = document.getElementById('empty');

    function applyFilters() {
      const q = (search.value || '').toLowerCase();
      const tagFilters = checks.filter(c => c.checked).map(c => c.value);

      let shown = 0;
      for (const card of cards) {
        const name = (card.dataset.name || '').toLowerCase();
        const desc = (card.dataset.desc || '').toLowerCase();
        const tags = (card.dataset.tags || '').split(',').filter(Boolean);

        const matchesQuery = !q || name.includes(q) || desc.includes(q) || tags.some(t => t.includes(q));
        const matchesTags = tagFilters.length === 0 || tagFilters.every(t => tags.includes(t));

        const show = matchesQuery && matchesTags;
        card.style.display = show ? 'block' : 'none';
        if (show) shown++;
      }

      empty.style.display = shown === 0 ? 'block' : 'none';

      document.querySelectorAll('.schema-section').forEach(section => {
        const visibleCards = section.querySelectorAll('.card');
        const anyVisible = Array.from(visibleCards).some(c => c.style.display !== 'none');
        section.style.display = anyVisible ? 'block' : 'none';
      });
    }

    search.addEventListener('input', applyFilters);
    checks.forEach(c => c.addEventListener('change', applyFilters));

    document.querySelectorAll('.copy').forEach(btn => {
      btn.addEventListener('click', async () => {
        const id = btn.dataset.copy;
        const pre = document.getElementById('sql-' + id);
        if (!pre) return;
        const text = pre.innerText;
        try {
          await navigator.clipboard.writeText(text);
          btn.textContent = 'Copied';
          setTimeout(() => (btn.textContent = 'Copy SQL'), 1200);
        } catch {
          btn.textContent = 'Copy failed';
          setTimeout(() => (btn.textContent = 'Copy SQL'), 1200);
        }
      });
    });

    applyFilters();
  </script>
</body>
</html>
'@

$html = $template.Replace('__TOTAL__', $total).Replace('__GENERATED__', $generated).Replace('__SIDEBAR_LINKS__', $sidebarLinks.ToString()).Replace('__SECTIONS__', $sections.ToString())

$indexHtmlPath = Join-Path $siteDir "index.html"
$procsHtmlPath = Join-Path $siteDir "procs.html"

$html | Out-File -FilePath $indexHtmlPath -Encoding utf8
$html | Out-File -FilePath $procsHtmlPath -Encoding utf8

Write-Host "Website generation complete!"
Write-Host "Open the following file to view the website:"
Write-Host "$indexHtmlPath"
