const sql = require('mssql');

async function listTablesDirect() {
  console.log('🔍 Connecting directly to HealthTime database...');

  const config = {
    server: 'INFOSDBT01\\INFOS01TST',
    database: 'healthtime',
    encrypt: false,
    trustServerCertificate: true,
    connectionTimeout: 30000,
    requestTimeout: 30000
  };

  try {
    console.log('📡 Establishing database connection...');
    const pool = new sql.ConnectionPool(config);
    await pool.connect();
    console.log('✅ Database connection established successfully!');

    console.log('📋 Querying for table list...');
    const result = await pool.request().query(`
      SELECT
        TABLE_SCHEMA,
        TABLE_NAME,
        TABLE_TYPE
      FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_TYPE = 'BASE TABLE'
      ORDER BY TABLE_SCHEMA, TABLE_NAME
    `);

    console.log('\n📊 TABLES IN HEALTHTIME DATABASE:');
    console.log('='.repeat(60));
    console.log(`Total Tables Found: ${result.recordset.length}`);
    console.log('='.repeat(60));

    if (result.recordset.length > 0) {
      result.recordset.forEach((table, index) => {
        console.log(`${(index + 1).toString().padStart(3, ' ')}. [${table.TABLE_SCHEMA}].[${table.TABLE_NAME}]`);
      });
    } else {
      console.log('No tables found in the database.');
    }

    console.log('\n✅ Query completed successfully!');
    await pool.close();
    console.log('🔌 Database connection closed.');

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.code) {
      console.error('Error Code:', error.code);
    }
    if (error.state) {
      console.error('Error State:', error.state);
    }
  }
}

// Run the function
listTablesDirect().catch(console.error);
