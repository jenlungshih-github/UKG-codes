# PowerShell script to generate a static HTML website from index.md and SQL files
# Run this script to create a browseable website in the docs/site folder

# Configuration Paths
$basePath = "C:\OneDrive-jlshih\OneDrive - University of California, San Diego Health\0Projects\Project TSR-UKG\00 Important files\1 Person Data"
$docsDir = Join-Path $basePath "docs"
$indexMdPath = Join-Path $docsDir "index.md"
$sqlSourceDir = Join-Path $docsDir "stored_procedures\sql"
$siteDir = Join-Path $docsDir "site"
$siteSqlDir = Join-Path $siteDir "sql"

# Ensure output directories exist
if (-not (Test-Path $siteSqlDir)) {
    New-Item -ItemType Directory -Force -Path $siteSqlDir | Out-Null
    Write-Host "Created directory: $siteSqlDir"
}

# 1. Create CSS file for styling
$cssContent = @"
body {
    font-family: 'Segoe UI', 'Segoe WP', Tahoma, Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    background-color: #f4f4f9;
    margin: 0;
    padding: 0;
}
.container {
    max-width: 1200px;
    margin: 40px auto;
    background: #fff;
    padding: 40px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    border-radius: 8px;
}
h1 {
    color: #005a9e;
    border-bottom: 2px solid #eee;
    padding-bottom: 10px;
}
h2 {
    color: #0078d4;
    margin-top: 30px;
    border-bottom: 1px solid #eee;
    padding-bottom: 5px;
}
a {
    color: #0078d4;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
ul.file-list {
    list-style: none;
    padding: 0;
}
ul.file-list li {
    padding: 12px 0;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
ul.file-list li:last-child {
    border-bottom: none;
}
.proc-name {
    font-weight: 600;
    font-size: 1.1em;
}
.proc-desc {
    color: #666;
    font-size: 0.95em;
    max-width: 600px;
    text-align: right;
}
pre {
    background-color: #f8f8f8;
    border: 1px solid #e1e1e8;
    border-radius: 4px;
    padding: 15px;
    overflow-x: auto;
    font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
    font-size: 13px;
    line-height: 1.5;
}
.back-link {
    display: inline-block;
    margin-bottom: 20px;
    font-size: 14px;
    color: #666;
}
footer {
    margin-top: 50px;
    text-align: center;
    font-size: 0.85em;
    color: #999;
    border-top: 1px solid #eee;
    padding-top: 20px;
}
"@
$cssPath = Join-Path $siteDir "style.css"
$cssContent | Out-File -FilePath $cssPath -Encoding utf8
Write-Host "Generated style.css"

# 2. Parse index.md and build HTML pages
Write-Host "Reading $indexMdPath..."
$indexMdContent = Get-Content $indexMdPath -Raw

# Regex to parse lines like: 1. [Name](./path) — Description
$regex = "\[(?<name>.*?)\]\(\./stored_procedures/sql/(?<file>.*?)\)\s+[-—]\s+(?<desc>.*)"
$matches = [regex]::Matches($indexMdContent, $regex)

$listItemsHtml = ""

foreach ($match in $matches) {
    $procName = $match.Groups["name"].Value
    $sqlFileName = $match.Groups["file"].Value
    $description = $match.Groups["desc"].Value
    
    $sourceSqlFile = Join-Path $sqlSourceDir $sqlFileName
    $destHtmlFile = Join-Path $siteSqlDir "$procName.html"
    
    # Read and escape SQL content
    $sqlContent = ""
    if (Test-Path $sourceSqlFile) {
        $sqlContent = Get-Content $sourceSqlFile -Raw
        $sqlContent = $sqlContent -replace "&", "&amp;" -replace "<", "&lt;" -replace ">", "&gt;"
    } else {
        $sqlContent = "-- Source file not found: $sqlFileName"
        Write-Warning "File not found: $sourceSqlFile"
    }

    # Generate Detail Page
    $detailHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$procName - SQL Documentation</title>
    <link rel="stylesheet" href="../style.css">
</head>
<body>
    <div class="container">
        <a href="../index.html" class="back-link">&larr; Back to Index</a>
        <h1>$procName</h1>
        <p class="description"><strong>Description:</strong> $description</p>
        <h2>SQL Definition</h2>
        <pre><code>$sqlContent</code></pre>
        <footer>Generated from: $sqlFileName</footer>
    </div>
</body>
</html>
"@
    $detailHtml | Out-File -FilePath $destHtmlFile -Encoding utf8

    # Add to index list
    $listItemsHtml += @"
            <li>
                <a href="sql/$procName.html" class="proc-name">$procName</a>
                <span class="proc-desc">$description</span>
            </li>
"@
}

# 3. Generate Main Index HTML
$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project TSR-UKG Stored Procedures</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Stored Procedures Documentation</h1>
        <p>Index of SQL stored procedures for Project TSR-UKG Person Data.</p>
        <ul class="file-list">
$listItemsHtml
        </ul>
        <footer>Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm")</footer>
    </div>
</body>
</html>
"@

$indexHtmlPath = Join-Path $siteDir "index.html"
$indexHtml | Out-File -FilePath $indexHtmlPath -Encoding utf8

Write-Host "Website generation complete!"
Write-Host "Open the following file to view the website:"
Write-Host "$indexHtmlPath"