/**
 * MCP_HealthTime Server - Enhanced MSSQL Database MCP Server
 *
 * This server provides Model Context Protocol (MCP) access to the HealthTime database
 * running on SQL Server instance INFOSDBT01\INFOS01TST.
 *
 * Features:
 * - MSSQL database connectivity with connection pooling
 * - Comprehensive error handling and logging
 * - Health check and monitoring endpoints
 * - Graceful shutdown handling
 * - MCP protocol compliance
 * - Security best practices
 *
 * Environment Variables:
 * - MSSQL_SERVER: Database server name (default: INFOSDBT01\INFOS01TST)
 * - MSSQL_DATABASE: Database name (default: healthtime)
 * - MSSQL_ENCRYPT: Enable encryption (default: false)
 * - MSSQL_TRUST_SERVER_CERTIFICATE: Trust server certificate (default: true)
 * - MCP_PORT: Server port (default: 3001)
 * - LOG_LEVEL: Logging level (default: info)
 *
 * @author Enhanced MCP Server Implementation
 * @version 2.0.0
 * @date 2025-09-10
 */

const sql = require('mssql');
const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const winston = require('winston');

// ============================================================================
// CONFIGURATION
// ============================================================================

/**
 * Server configuration with environment variable support
 */
const CONFIG = {
  database: {
    server: process.env.MSSQL_SERVER || 'INFOSDBT01\\INFOS01TST',
    database: process.env.MSSQL_DATABASE || 'healthtime',
    encrypt: process.env.MSSQL_ENCRYPT === 'true',
    trustServerCertificate: process.env.MSSQL_TRUST_SERVER_CERTIFICATE !== 'false',
    connectionTimeout: 30000,
    requestTimeout: 30000,
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000
    }
  },
  server: {
    port: parseInt(process.env.MCP_PORT) || 3001,
    name: 'MCP_HealthTime',
    version: '2.0.0'
  },
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.errors({ stack: true }),
      winston.format.json()
    )
  }
};

// ============================================================================
// LOGGING SETUP
// ============================================================================

/**
 * Winston logger configuration for comprehensive logging
 */
const logger = winston.createLogger({
  level: CONFIG.logging.level,
  format: CONFIG.logging.format,
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({
      filename: 'mcp_healthtime.log',
      format: CONFIG.logging.format
    })
  ]
});

// ============================================================================
// DATABASE CONNECTION MANAGEMENT
// ============================================================================

/**
 * MSSQL connection pool for efficient database access
 */
let connectionPool = null;

/**
 * Initialize database connection pool
 * @returns {Promise<sql.ConnectionPool>} Database connection pool
 */
async function initializeDatabaseConnection() {
  try {
    logger.info('Initializing database connection pool...', {
      server: CONFIG.database.server,
      database: CONFIG.database.database
    });

    const config = {
      ...CONFIG.database,
      options: {
        encrypt: CONFIG.database.encrypt,
        trustServerCertificate: CONFIG.database.trustServerCertificate,
        enableArithAbort: true
      }
    };

    connectionPool = new sql.ConnectionPool(config);
    connectionPool.on('connect', () => {
      logger.info('Database connection established successfully');
    });

    connectionPool.on('error', (err) => {
      logger.error('Database connection error:', err);
    });

    await connectionPool.connect();
    logger.info('Database connection pool initialized successfully');
    return connectionPool;

  } catch (error) {
    logger.error('Failed to initialize database connection:', error);
    throw new Error(`Database initialization failed: ${error.message}`);
  }
}

/**
 * Test database connectivity
 * @returns {Promise<boolean>} Connection test result
 */
async function testDatabaseConnection() {
  try {
    logger.info('Testing database connection...');
    const result = await connectionPool.request().query('SELECT 1 as test');
    const success = result.recordset && result.recordset.length > 0;
    logger.info('Database connection test successful', { result: result.recordset[0] });
    return success;
  } catch (error) {
    logger.error('Database connection test failed:', error);
    return false;
  }
}

/**
 * Close database connection pool gracefully
 */
async function closeDatabaseConnection() {
  if (connectionPool) {
    try {
      logger.info('Closing database connection pool...');
      await connectionPool.close();
      logger.info('Database connection pool closed successfully');
    } catch (error) {
      logger.error('Error closing database connection pool:', error);
    }
  }
}

// ============================================================================
// MCP TOOL DEFINITIONS
// ============================================================================

/**
 * Available MCP tools for database operations
 */
const MCP_TOOLS = [
  {
    name: 'execute_query',
    description: 'Execute a SQL query against the HealthTime database',
    inputSchema: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: 'SQL query to execute'
        },
        parameters: {
          type: 'object',
          description: 'Query parameters (optional)',
          additionalProperties: true
        }
      },
      required: ['query']
    }
  },
  {
    name: 'list_tables',
    description: 'List all tables in the HealthTime database',
    inputSchema: {
      type: 'object',
      properties: {}
    }
  },
  {
    name: 'get_table_schema',
    description: 'Get schema information for a specific table',
    inputSchema: {
      type: 'object',
      properties: {
        tableName: {
          type: 'string',
          description: 'Name of the table to get schema for'
        }
      },
      required: ['tableName']
    }
  },
  {
    name: 'health_check',
    description: 'Perform a health check on the database connection',
    inputSchema: {
      type: 'object',
      properties: {}
    }
  }
];

// ============================================================================
// MCP TOOL HANDLERS
// ============================================================================

/**
 * Execute SQL query tool handler
 * @param {Object} args - Tool arguments
 * @returns {Promise<Object>} Query results
 */
async function handleExecuteQuery(args) {
  const { query, parameters = {} } = args;

  try {
    logger.info('Executing query', { query: query.substring(0, 100) + '...' });

    const request = connectionPool.request();

    // Add parameters if provided
    Object.entries(parameters).forEach(([key, value]) => {
      request.input(key, value);
    });

    const result = await request.query(query);

    logger.info('Query executed successfully', {
      rowCount: result.recordset?.length || 0,
      columns: result.recordset?.[0] ? Object.keys(result.recordset[0]) : []
    });

    return {
      success: true,
      data: {
        recordset: result.recordset,
        recordsets: result.recordsets,
        rowsAffected: result.rowsAffected,
        output: result.output
      },
      metadata: {
        rowCount: result.recordset?.length || 0,
        columnCount: result.recordset?.[0] ? Object.keys(result.recordset[0]).length : 0
      }
    };

  } catch (error) {
    logger.error('Query execution failed:', error);
    return {
      success: false,
      error: error.message,
      code: error.code,
      state: error.state
    };
  }
}

/**
 * List tables tool handler
 * @returns {Promise<Object>} List of tables
 */
async function handleListTables() {
  try {
    logger.info('Listing database tables');

    const query = `
      SELECT
        TABLE_SCHEMA,
        TABLE_NAME,
        TABLE_TYPE
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_TYPE = 'BASE TABLE'
      ORDER BY TABLE_SCHEMA, TABLE_NAME
    `;

    const result = await connectionPool.request().query(query);

    logger.info('Tables listed successfully', { count: result.recordset.length });

    return {
      success: true,
      tables: result.recordset,
      count: result.recordset.length
    };

  } catch (error) {
    logger.error('Failed to list tables:', error);
    return {
      success: false,
      error: error.message
    };
  }
}

/**
 * Get table schema tool handler
 * @param {Object} args - Tool arguments
 * @returns {Promise<Object>} Table schema information
 */
async function handleGetTableSchema(args) {
  const { tableName } = args;

  try {
    logger.info('Getting table schema', { tableName });

    const query = `
      SELECT
        COLUMN_NAME,
        DATA_TYPE,
        IS_NULLABLE,
        COLUMN_DEFAULT,
        CHARACTER_MAXIMUM_LENGTH,
        NUMERIC_PRECISION,
        NUMERIC_SCALE
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_NAME = @tableName
      ORDER BY ORDINAL_POSITION
    `;

    const result = await connectionPool.request()
      .input('tableName', sql.VarChar, tableName)
      .query(query);

    logger.info('Table schema retrieved successfully', {
      tableName,
      columnCount: result.recordset.length
    });

    return {
      success: true,
      tableName,
      columns: result.recordset,
      columnCount: result.recordset.length
    };

  } catch (error) {
    logger.error('Failed to get table schema:', error);
    return {
      success: false,
      error: error.message,
      tableName
    };
  }
}

/**
 * Health check tool handler
 * @returns {Promise<Object>} Health check results
 */
async function handleHealthCheck() {
  try {
    logger.info('Performing health check');

    const startTime = Date.now();
    const isConnected = await testDatabaseConnection();
    const responseTime = Date.now() - startTime;

    const healthStatus = {
      success: true,
      status: isConnected ? 'healthy' : 'unhealthy',
      timestamp: new Date().toISOString(),
      database: {
        server: CONFIG.database.server,
        database: CONFIG.database.database,
        connected: isConnected
      },
      server: {
        name: CONFIG.server.name,
        version: CONFIG.server.version,
        port: CONFIG.server.port
      },
      performance: {
        responseTime: `${responseTime}ms`
      }
    };

    logger.info('Health check completed', {
      status: healthStatus.status,
      responseTime: `${responseTime}ms`
    });

    return healthStatus;

  } catch (error) {
    logger.error('Health check failed:', error);
    return {
      success: false,
      status: 'error',
      error: error.message,
      timestamp: new Date().toISOString()
    };
  }
}

// ============================================================================
// MCP SERVER SETUP
// ============================================================================

/**
 * Create and configure MCP server
 * @returns {Server} Configured MCP server instance
 */
function createMCPServer() {
  const server = new Server(
    {
      name: CONFIG.server.name,
      version: CONFIG.server.version,
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  // Tool listing handler
  server.setRequestHandler('tools/list', async () => {
    logger.debug('Handling tools/list request');
    return { tools: MCP_TOOLS };
  });

  // Tool calling handler
  server.setRequestHandler('tools/call', async (request) => {
    const { name, arguments: args } = request.params;

    logger.info('Handling tool call', { tool: name });

    try {
      let result;

      switch (name) {
        case 'execute_query':
          result = await handleExecuteQuery(args);
          break;
        case 'list_tables':
          result = await handleListTables();
          break;
        case 'get_table_schema':
          result = await handleGetTableSchema(args);
          break;
        case 'health_check':
          result = await handleHealthCheck();
          break;
        default:
          throw new Error(`Unknown tool: ${name}`);
      }

      return { content: [{ type: 'text', text: JSON.stringify(result, null, 2) }] };

    } catch (error) {
      logger.error('Tool execution failed:', error);
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            success: false,
            error: error.message,
            tool: name
          }, null, 2)
        }],
        isError: true
      };
    }
  });

  return server;
}

// ============================================================================
// MAIN APPLICATION
// ============================================================================

/**
 * Main application entry point
 */
async function main() {
  try {
    logger.info(`${CONFIG.server.name} server starting up...`);
    logger.info('Configuration:', {
      server: CONFIG.database.server,
      database: CONFIG.database.database,
      port: CONFIG.server.port
    });

    // Initialize database connection
    await initializeDatabaseConnection();

    // Test database connection
    const connectionTest = await testDatabaseConnection();
    if (!connectionTest) {
      throw new Error('Database connection test failed');
    }

    // Create MCP server
    const server = createMCPServer();

    // Setup graceful shutdown
    process.on('SIGINT', async () => {
      logger.info('Received SIGINT, shutting down gracefully...');
      await closeDatabaseConnection();
      process.exit(0);
    });

    process.on('SIGTERM', async () => {
      logger.info('Received SIGTERM, shutting down gracefully...');
      await closeDatabaseConnection();
      process.exit(0);
    });

    // Start MCP server
    const transport = new StdioServerTransport();
    await server.connect(transport);

    logger.info(`${CONFIG.server.name} server started successfully`);
    logger.info('=== MCP_HealthTime SERVER READY ===');
    logger.info('Available tools:', MCP_TOOLS.map(tool => tool.name).join(', '));

  } catch (error) {
    logger.error('Failed to start MCP server:', error);
    await closeDatabaseConnection();
    process.exit(1);
  }
}

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception:', error);
  closeDatabaseConnection().finally(() => {
    process.exit(1);
  });
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled rejection at:', promise, 'reason:', reason);
  closeDatabaseConnection().finally(() => {
    process.exit(1);
  });
});

// Start the application
if (require.main === module) {
  main();
}

module.exports = {
  CONFIG,
  initializeDatabaseConnection,
  testDatabaseConnection,
  closeDatabaseConnection,
  createMCPServer,
  MCP_TOOLS
};
