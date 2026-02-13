-- Query to get the correct list of stored procedures in dbo, stage, hts schemas

SELECT SCHEMA_NAME(o.schema_id) + '.' + o.name AS procedure_name
FROM sys.objects o
WHERE o.type = 'P' AND SCHEMA_NAME(o.schema_id) IN ('dbo', 'stage', 'hts')
ORDER BY SCHEMA_NAME(o.schema_id), o.name;