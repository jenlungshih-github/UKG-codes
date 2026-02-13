-- List of stored procedures in stage schema
SELECT SCHEMA_NAME(o.schema_id) AS schema_name, o.name AS procedure_name
FROM sys.objects o
WHERE o.type = 'P' AND SCHEMA_NAME(o.schema_id) = 'stage'
ORDER BY o.name;