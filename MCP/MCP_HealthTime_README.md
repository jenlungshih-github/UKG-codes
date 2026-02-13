# MCP_HealthTime Server - Enhanced Documentation

## Overview

The **MCP_HealthTime Server** is an enhanced Model Context Protocol (MCP) server that provides secure, efficient, and well-documented access to the HealthTime MSSQL database. This server is designed for production use with comprehensive error handling, logging, monitoring, and security features.

## 🚀 Key Features

### Core Functionality
- **MSSQL Database Connectivity** - Robust connection pooling for optimal performance
- **MCP Protocol Compliance** - Full adherence to Model Context Protocol standards
- **Comprehensive Tool Set** - Four powerful database operation tools
- **Health Monitoring** - Built-in health checks and status monitoring

### Enterprise-Grade Features
- **Advanced Logging** - Winston-based logging with multiple transports
- **Error Handling** - Comprehensive error handling with detailed error reporting
- **Graceful Shutdown** - Proper cleanup and resource management
- **Security Best Practices** - Secure configuration and connection handling
- **Performance Monitoring** - Connection pooling and query performance tracking

### Developer Experience
- **Extensive Documentation** - Comprehensive inline documentation
- **Modular Architecture** - Clean separation of concerns
- **Environment Configuration** - Flexible configuration via environment variables
- **Type Safety** - Well-structured code with clear interfaces

## 📋 Prerequisites

### System Requirements
- **Node.js**: Version 16.0.0 or higher
- **MSSQL Server**: Accessible SQL Server instance
- **Network Access**: Ability to connect to the database server

### Required NPM Packages
```bash
npm install mssql @modelcontextprotocol/sdk winston
```

### Database Permissions
The database user must have appropriate permissions for:
- SELECT operations on system tables (INFORMATION_SCHEMA)
- EXECUTE permissions on target database objects
- Connection permissions to the specified database

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MSSQL_SERVER` | `INFOSDBT01\INFOS01TST` | SQL Server instance name |
| `MSSQL_DATABASE` | `healthtime` | Target database name |
| `MSSQL_ENCRYPT` | `false` | Enable TLS encryption |
| `MSSQL_TRUST_SERVER_CERTIFICATE` | `true` | Trust server SSL certificate |
| `MCP_PORT` | `3001` | Server port (not used in stdio mode) |
| `LOG_LEVEL` | `info` | Logging level (error, warn, info, debug) |

### Connection Pool Configuration
```javascript
const poolConfig = {
  max: 10,           // Maximum connections
  min: 0,            // Minimum connections
  idleTimeoutMillis: 30000,  // Close idle connections after 30s
  connectionTimeout: 30000,  // Connection timeout
  requestTimeout: 30000      // Query timeout
};
```

## 🛠️ Available Tools

### 1. `execute_query`
Execute SQL queries against the HealthTime database with parameter support.

**Parameters:**
- `query` (string, required): SQL query to execute
- `parameters` (object, optional): Query parameters

**Example:**
```json
{
  "query": "SELECT * FROM employees WHERE department = @dept",
  "parameters": {
    "dept": "IT"
  }
}
```

### 2. `list_tables`
Retrieve a list of all tables in the HealthTime database.

**Parameters:** None

**Returns:**
- List of tables with schema information
- Table count
- Success status

### 3. `get_table_schema`
Get detailed schema information for a specific table.

**Parameters:**
- `tableName` (string, required): Name of the table

**Returns:**
- Column definitions
- Data types
- Constraints
- Nullability information

### 4. `health_check`
Perform a comprehensive health check of the database connection and server status.

**Parameters:** None

**Returns:**
- Connection status
- Server information
- Performance metrics
- Timestamp

## 🚀 Installation & Setup

### 1. Install Dependencies
```bash
cd /path/to/mcp/server
npm install mssql @modelcontextprotocol/sdk winston
```

### 2. Configure Environment
Create a `.env` file or set environment variables:
```bash
export MSSQL_SERVER="INFOSDBT01\\INFOS01TST"
export MSSQL_DATABASE="healthtime"
export MSSQL_ENCRYPT="false"
export MSSQL_TRUST_SERVER_CERTIFICATE="true"
export LOG_LEVEL="info"
```

### 3. Update MCP Configuration
Add to your VS Code `mcp.json`:
```json
{
  "mcpServers": {
    "MCP_HealthTime": {
      "command": "node",
      "args": ["/path/to/improved_mcp_healthtime_server.js"],
      "cwd": "/path/to/mcp/directory",
      "env": {
        "MSSQL_SERVER": "INFOSDBT01\\INFOS01TST",
        "MSSQL_DATABASE": "healthtime",
        "MSSQL_ENCRYPT": "false",
        "MSSQL_TRUST_SERVER_CERTIFICATE": "true"
      }
    }
  }
}
```

### 4. Start the Server
```bash
node improved_mcp_healthtime_server.js
```

## 📊 Monitoring & Logging

### Log Files
- **Console Output**: Real-time logs with color coding
- **File Logging**: `mcp_healthtime.log` with structured JSON format

### Log Levels
- `error`: Critical errors only
- `warn`: Warnings and errors
- `info`: General information (default)
- `debug`: Detailed debugging information

### Health Monitoring
The server provides built-in health monitoring:
```javascript
// Example health check response
{
  "success": true,
  "status": "healthy",
  "timestamp": "2025-09-10T21:15:03.372Z",
  "database": {
    "server": "INFOSDBT01\\INFOS01TST",
    "database": "healthtime",
    "connected": true
  },
  "server": {
    "name": "MCP_HealthTime",
    "version": "2.0.0"
  },
  "performance": {
    "responseTime": "45ms"
  }
}
```

## 🔒 Security Considerations

### Database Security
- Use parameterized queries to prevent SQL injection
- Implement proper authentication and authorization
- Regularly rotate database credentials
- Monitor database access logs

### Network Security
- Use encrypted connections when possible (`MSSQL_ENCRYPT=true`)
- Implement proper firewall rules
- Use VPN for remote access
- Regularly update SSL certificates

### Application Security
- Validate all input parameters
- Implement proper error handling
- Use secure logging practices
- Regularly update dependencies

## 🐛 Troubleshooting

### Common Issues

#### Connection Failed
```
Error: Server INFOSDBT01\INFOS01TST not found
```
**Solutions:**
- Verify server name and instance
- Check network connectivity
- Ensure SQL Server Browser service is running
- Confirm firewall settings

#### Authentication Failed
```
Error: Login failed for user
```
**Solutions:**
- Verify username and password
- Check user permissions
- Ensure correct database is specified
- Confirm authentication method

#### Timeout Errors
```
Error: Timeout expired
```
**Solutions:**
- Increase connection timeout
- Check network latency
- Verify server performance
- Reduce connection pool size

### Debug Mode
Enable detailed logging:
```bash
export LOG_LEVEL=debug
node improved_mcp_healthtime_server.js
```

## 📈 Performance Optimization

### Connection Pool Tuning
```javascript
const optimalPoolConfig = {
  max: 20,           // Increase for high concurrency
  min: 5,            // Maintain minimum connections
  idleTimeoutMillis: 60000,  // Longer idle timeout
  acquireTimeoutMillis: 60000,  // Longer acquire timeout
  createTimeoutMillis: 30000   // Connection creation timeout
};
```

### Query Optimization
- Use parameterized queries
- Implement proper indexing
- Avoid SELECT * in production
- Use appropriate WHERE clauses

### Monitoring Queries
```sql
-- Monitor active connections
SELECT * FROM sys.dm_exec_connections;

-- Monitor connection pool
SELECT * FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%SQL Statistics%';
```

## 🔄 API Reference

### MCP Protocol Compliance

The server fully implements the MCP protocol with the following endpoints:

#### `tools/list`
Returns the list of available tools.

#### `tools/call`
Executes a specific tool with provided arguments.

### Response Format
All responses follow a consistent format:
```json
{
  "success": true|false,
  "data": { ... },           // Tool-specific data
  "error": "error message",  // Only present on errors
  "metadata": { ... }        // Additional information
}
```

## 🤝 Contributing

### Code Style
- Use async/await for asynchronous operations
- Implement comprehensive error handling
- Add JSDoc comments for all functions
- Follow consistent naming conventions
- Use ES6+ features appropriately

### Testing
```bash
# Run health check
npm test health_check

# Test database connection
npm test connection

# Run all tests
npm test
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
1. Check the troubleshooting section
2. Review the logs for error details
3. Verify configuration settings
4. Test database connectivity independently

## 📝 Changelog

### Version 2.0.0 (2025-09-10)
- ✅ Complete rewrite with enterprise features
- ✅ Added comprehensive logging with Winston
- ✅ Implemented connection pooling
- ✅ Added health check functionality
- ✅ Enhanced error handling and recovery
- ✅ Added graceful shutdown handling
- ✅ Improved security and configuration
- ✅ Added extensive documentation
- ✅ Modular architecture for maintainability

### Version 1.0.0 (Previous)
- Basic MCP server functionality
- Simple database connectivity
- Limited error handling
- Minimal logging

---

**Author:** Enhanced MCP Server Implementation
**Version:** 2.0.0
**Date:** 2025-09-10
**Contact:** System Administrator
