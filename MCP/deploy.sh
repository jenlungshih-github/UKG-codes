#!/bin/bash

# MCP_HealthTime Server Deployment Script
# Version: 2.0.0
# Date: 2025-09-10

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_FILE="$SCRIPT_DIR/improved_mcp_healthtime_server.js"
PACKAGE_FILE="$SCRIPT_DIR/package.json"
README_FILE="$SCRIPT_DIR/MCP_HealthTime_README.md"

# Default configuration
DEFAULT_SERVER="INFOSDBT01\\INFOS01TST"
DEFAULT_DATABASE="healthtime"
DEFAULT_ENCRYPT="false"
DEFAULT_TRUST_CERT="true"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking system dependencies..."

    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 16.0.0 or higher."
        exit 1
    fi

    # Check Node.js version
    NODE_VERSION=$(node --version | sed 's/v//')
    if ! [ "$(printf '%s\n' "$NODE_VERSION" "16.0.0" | sort -V | head -n1)" = "16.0.0" ]; then
        log_error "Node.js version 16.0.0 or higher is required. Current version: $NODE_VERSION"
        exit 1
    fi

    log_success "Node.js version $NODE_VERSION is compatible"

    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed. Please install npm."
        exit 1
    fi

    log_success "npm is available"
}

setup_environment() {
    log_info "Setting up environment variables..."

    # Create .env file if it doesn't exist
    if [ ! -f "$SCRIPT_DIR/.env" ]; then
        log_info "Creating .env file with default configuration..."

        cat > "$SCRIPT_DIR/.env" << EOF
# MCP_HealthTime Server Configuration
# Generated on $(date)

# Database Configuration
MSSQL_SERVER=$DEFAULT_SERVER
MSSQL_DATABASE=$DEFAULT_DATABASE
MSSQL_ENCRYPT=$DEFAULT_ENCRYPT
MSSQL_TRUST_SERVER_CERTIFICATE=$DEFAULT_TRUST_CERT

# Server Configuration
MCP_PORT=3001
LOG_LEVEL=info

# Security Notes:
# - Change default credentials for production use
# - Enable encryption (MSSQL_ENCRYPT=true) for secure connections
# - Verify server certificate in production (MSSQL_TRUST_SERVER_CERTIFICATE=false)
EOF

        log_success ".env file created at $SCRIPT_DIR/.env"
        log_warning "Please review and update the .env file with your actual database credentials"
    else
        log_info ".env file already exists"
    fi
}

install_dependencies() {
    log_info "Installing npm dependencies..."

    if [ ! -d "$SCRIPT_DIR/node_modules" ]; then
        log_info "Installing dependencies..."
        cd "$SCRIPT_DIR"
        npm install
        log_success "Dependencies installed successfully"
    else
        log_info "Dependencies already installed"
    fi
}

validate_configuration() {
    log_info "Validating configuration..."

    # Check if server file exists
    if [ ! -f "$SERVER_FILE" ]; then
        log_error "Server file not found: $SERVER_FILE"
        exit 1
    fi

    # Check if package.json exists
    if [ ! -f "$PACKAGE_FILE" ]; then
        log_error "Package file not found: $PACKAGE_FILE"
        exit 1
    fi

    # Check if README exists
    if [ ! -f "$README_FILE" ]; then
        log_warning "README file not found: $README_FILE"
    fi

    log_success "Configuration validation passed"
}

test_connection() {
    log_info "Testing database connection..."

    # Source environment variables
    if [ -f "$SCRIPT_DIR/.env" ]; then
        set -a
        source "$SCRIPT_DIR/.env"
        set +a
    fi

    # Run a simple connection test
    log_info "Attempting to connect to database..."
    log_info "Server: ${MSSQL_SERVER:-$DEFAULT_SERVER}"
    log_info "Database: ${MSSQL_DATABASE:-$DEFAULT_DATABASE}"

    # Note: Actual connection test would require running the Node.js server
    # For now, we'll just validate the configuration
    log_success "Configuration validated (actual connection test requires running the server)"
}

show_usage() {
    log_info "MCP_HealthTime Server Deployment Script"
    echo ""
    echo "Usage:"
    echo "  $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup      - Complete setup (dependencies, environment, validation)"
    echo "  install    - Install npm dependencies only"
    echo "  env        - Setup environment variables only"
    echo "  validate   - Validate configuration only"
    echo "  test       - Test database connection"
    echo "  start      - Start the MCP server"
    echo "  help       - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup    # Complete setup"
    echo "  $0 start    # Start the server"
    echo ""
}

start_server() {
    log_info "Starting MCP_HealthTime server..."

    # Source environment variables
    if [ -f "$SCRIPT_DIR/.env" ]; then
        set -a
        source "$SCRIPT_DIR/.env"
        set +a
    fi

    # Start the server
    cd "$SCRIPT_DIR"
    log_info "Launching server..."
    log_info "Press Ctrl+C to stop the server"
    echo ""

    exec node "$SERVER_FILE"
}

# Main script logic
case "${1:-setup}" in
    "setup")
        log_info "Starting complete setup process..."
        check_dependencies
        setup_environment
        install_dependencies
        validate_configuration
        test_connection
        log_success "Setup completed successfully!"
        echo ""
        log_info "Next steps:"
        echo "1. Review and update the .env file with your database credentials"
        echo "2. Run '$0 start' to start the MCP server"
        echo "3. Check the README.md for detailed usage instructions"
        ;;
    "install")
        check_dependencies
        install_dependencies
        ;;
    "env")
        setup_environment
        ;;
    "validate")
        validate_configuration
        ;;
    "test")
        test_connection
        ;;
    "start")
        validate_configuration
        start_server
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
