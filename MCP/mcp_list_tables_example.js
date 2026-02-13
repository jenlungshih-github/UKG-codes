/**
 * Simple MCP Client Example - Use MCP_HealthTime Server Tools
 *
 * This script demonstrates how to connect to the running MCP_HealthTime server
 * and use its tools to execute queries.
 *
 * Prerequisites:
 * - MCP_HealthTime server must be running
 * - Node.js with @modelcontextprotocol/sdk installed
 *
 * Usage:
 * node mcp_list_tables_example.js
 */

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";

class SimpleMCPClient {
  constructor(serverPath, cwd, env) {
    this.serverPath = serverPath;
    this.cwd = cwd;
    this.env = { ...process.env, ...env };
    this.client = null;
    this.transport = null;
  }

  async start() {
    return new Promise((resolve, reject) => {
      console.log('🚀 Starting MCP_HealthTime server...');

      this.transport = new StdioClientTransport({
        command: 'node',
        args: [this.serverPath],
        env: this.env
      });

      this.client = new Client(
        {
          name: "simple-mcp-client",
          version: "1.0.0",
        },
        {
          capabilities: {},
        }
      );

      this.client.connect(this.transport).then(() => {
        console.log('✅ MCP client connected!');
        resolve();
      }).catch(reject);

      // Timeout after 30 seconds
      setTimeout(() => {
        reject(new Error('Client connection timeout'));
      }, 30000);
    });
  }

  async callSimpleQuery(query) {
    console.log('📋 Calling simple_query tool...');

    try {
      const result = await this.client.callTool({
        name: "simple_query",
        arguments: {
          query: query
        }
      });

      console.log('✅ Query result:', result);
      return result;
    } catch (error) {
      console.error('❌ Error calling tool:', error);
      throw error;
    }
  }

  async stop() {
    if (this.client) {
      await this.client.close();
      console.log('✅ MCP client disconnected');
    }
    if (this.transport) {
      // The transport may handle closing the process
      console.log('✅ MCP transport closed');
    }
  }
}

// Main execution
async function main() {
  const client = new SimpleMCPClient(
    'c:\\TRAE\\MCP_2\\simple_mcp_healthtime_server.js',
    'c:\\TRAE\\MCP_2',
    {
      MSSQL_SERVER: 'INFOSDBT01\\INFOS01TST',
      MSSQL_DATABASE: 'healthtime',
      MSSQL_ENCRYPT: 'false',
      MSSQL_TRUST_SERVER_CERTIFICATE: 'true'
    }
  );

  try {
    // Start the MCP server and connect client
    await client.start();

    // Call the simple_query tool
    const result = await client.callSimpleQuery("SELECT name FROM sys.tables;");

    console.log('\n📊 Query Results:');
    console.log('='.repeat(50));
    console.log(JSON.stringify(result, null, 2));

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.stop();
  }
}

// Run the example
main().catch(console.error);

export default SimpleMCPClient;
