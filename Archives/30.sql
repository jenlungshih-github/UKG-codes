-- HealthTime-PROD Connection Test
-- Created: 2025-11-20

-- Test 1: Check server version and instance
SELECT 
    @@VERSION AS ServerVersion,
    @@SERVERNAME AS ServerName,
    DB_NAME() AS CurrentDatabase;

-- Test 2: Check current user and authentication
SELECT 
    SYSTEM_USER AS SystemUser,
    USER_NAME() AS DatabaseUser,
    SUSER_NAME() AS LoginName,
    GETDATE() AS CurrentDateTime;

-- Test 3: List all tables in HealthTime database
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- Test 4: Count tables by schema
SELECT 
    TABLE_SCHEMA,
    COUNT(*) AS TableCount
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
GROUP BY TABLE_SCHEMA
ORDER BY TableCount DESC;