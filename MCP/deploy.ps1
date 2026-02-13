# MCP_HealthTime Server Deployment Script
# Version: 2.0.0
# Date: 2025-09-10
# PowerShell Version for Windows

param(
    [string]$Command = "setup",
    [switch]$Help
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ServerFile = Join-Path $ScriptDir "improved_mcp_healthtime_server.js"
$PackageFile = Join-Path $ScriptDir "package.json"
$ReadmeFile = Join-Path $ScriptDir "MCP_HealthTime_README.md"
$EnvFile = Join-Path $ScriptDir ".env"

# Default configuration
$DefaultServer = "INFOSDBT01\INFOS01TST"
$DefaultDatabase = "healthtime"
$DefaultEncrypt = "false"
$DefaultTrustCert = "true"

# Colors for output (PowerShell)
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Cyan"
    White = "White"
}

function Write-ColorOutput {
    param(
        [string]$Color,
        [string]$Level,
        [string]$Message
    )
    Write-Host "[$Level] $Message" -ForegroundColor $Colors[$Color]
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "Blue" "INFO" $Message
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "Green" "SUCCESS" $Message
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "Yellow" "WARNING" $Message
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "Red" "ERROR" $Message
}

function Test-Dependencies {
    Write-Info "Checking system dependencies..."

    # Check Node.js
    try {
        $nodeVersion = & node --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Node.js not found"
        }
        Write-Info "Node.js version: $nodeVersion"

        # Extract version number
        $versionNumber = $nodeVersion -replace '^v', ''
        $minVersion = [version]"16.0.0"
        $currentVersion = [version]$versionNumber

        if ($currentVersion -lt $minVersion) {
            Write-Error "Node.js version 16.0.0 or higher is required. Current: $versionNumber"
            exit 1
        }
        Write-Success "Node.js version is compatible"
    }
    catch {
        Write-Error "Node.js is not installed or not accessible"
        Write-Info "Please install Node.js from https://nodejs.org/"
        exit 1
    }

    # Check npm
    try {
        $npmVersion = & npm --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "npm not found"
        }
        Write-Success "npm version: $npmVersion"
    }
    catch {
        Write-Error "npm is not installed"
        exit 1
    }
}

function Setup-Environment {
    Write-Info "Setting up environment variables..."

    if (-not (Test-Path $EnvFile)) {
        Write-Info "Creating .env file with default configuration..."

        $envContent = @"
# MCP_HealthTime Server Configuration
# Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Database Configuration
MSSQL_SERVER=$DefaultServer
MSSQL_DATABASE=$DefaultDatabase
MSSQL_ENCRYPT=$DefaultEncrypt
MSSQL_TRUST_SERVER_CERTIFICATE=$DefaultTrustCert

# Server Configuration
MCP_PORT=3001
LOG_LEVEL=info

# Security Notes:
# - Change default credentials for production use
# - Enable encryption (MSSQL_ENCRYPT=true) for secure connections
# - Verify server certificate in production (MSSQL_TRUST_SERVER_CERTIFICATE=false)
"@

        $envContent | Out-File -FilePath $EnvFile -Encoding UTF8
        Write-Success ".env file created at $EnvFile"
        Write-Warning "Please review and update the .env file with your actual database credentials"
    }
    else {
        Write-Info ".env file already exists"
    }
}

function Install-Dependencies {
    Write-Info "Installing npm dependencies..."

    if (-not (Test-Path (Join-Path $ScriptDir "node_modules"))) {
        Write-Info "Installing dependencies..."
        Push-Location $ScriptDir
        try {
            & npm install
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Dependencies installed successfully"
            }
            else {
                Write-Error "Failed to install dependencies"
                exit 1
            }
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Info "Dependencies already installed"
    }
}

function Test-Configuration {
    Write-Info "Validating configuration..."

    # Check server file
    if (-not (Test-Path $ServerFile)) {
        Write-Error "Server file not found: $ServerFile"
        exit 1
    }

    # Check package.json
    if (-not (Test-Path $PackageFile)) {
        Write-Error "Package file not found: $PackageFile"
        exit 1
    }

    # Check README
    if (-not (Test-Path $ReadmeFile)) {
        Write-Warning "README file not found: $ReadmeFile"
    }

    Write-Success "Configuration validation passed"
}

function Test-DatabaseConnection {
    Write-Info "Testing database connection configuration..."

    # Load environment variables
    if (Test-Path $EnvFile) {
        Get-Content $EnvFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                Set-Item -Path "env:$key" -Value $value
            }
        }
    }

    Write-Info "Configuration to be used:"
    Write-Info "Server: $($env:MSSQL_SERVER, $DefaultServer -ne $null)[0]"
    Write-Info "Database: $($env:MSSQL_DATABASE, $DefaultDatabase -ne $null)[0]"

    Write-Success "Configuration validated (actual connection test requires running the server)"
}

function Start-Server {
    Write-Info "Starting MCP_HealthTime server..."

    # Load environment variables
    if (Test-Path $EnvFile) {
        Get-Content $EnvFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim()
                Set-Item -Path "env:$key" -Value $value
            }
        }
    }

    Test-Configuration

    Write-Info "Launching server..."
    Write-Info "Press Ctrl+C to stop the server"
    Write-Host ""

    # Start the server
    Push-Location $ScriptDir
    try {
        & node $ServerFile
    }
    finally {
        Pop-Location
    }
}

function Show-Usage {
    Write-Info "MCP_HealthTime Server Deployment Script (PowerShell)"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\deploy.ps1 [-Command] <command>"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  setup      - Complete setup (dependencies, environment, validation)"
    Write-Host "  install    - Install npm dependencies only"
    Write-Host "  env        - Setup environment variables only"
    Write-Host "  validate   - Validate configuration only"
    Write-Host "  test       - Test database connection configuration"
    Write-Host "  start      - Start the MCP server"
    Write-Host "  help       - Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\deploy.ps1 -Command setup    # Complete setup"
    Write-Host "  .\deploy.ps1 -Command start    # Start the server"
    Write-Host ""
}

# Main script logic
if ($Help) {
    Show-Usage
    exit 0
}

switch ($Command) {
    "setup" {
        Write-Info "Starting complete setup process..."
        Test-Dependencies
        Setup-Environment
        Install-Dependencies
        Test-Configuration
        Test-DatabaseConnection
        Write-Success "Setup completed successfully!"
        Write-Host ""
        Write-Info "Next steps:"
        Write-Host "1. Review and update the .env file with your database credentials"
        Write-Host "2. Run '.\deploy.ps1 -Command start' to start the MCP server"
        Write-Host "3. Check the README.md for detailed usage instructions"
    }
    "install" {
        Test-Dependencies
        Install-Dependencies
    }
    "env" {
        Setup-Environment
    }
    "validate" {
        Test-Configuration
    }
    "test" {
        Test-DatabaseConnection
    }
    "start" {
        Start-Server
    }
    "help" {
        Show-Usage
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host ""
        Show-Usage
        exit 1
    }
}
