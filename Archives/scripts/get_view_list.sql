-- List all views in dbo, hts, and stage schemas
SELECT SCHEMA_NAME(o.schema_id) + '.' + o.name AS view_name
FROM sys.objects o
WHERE o.type = 'V' AND SCHEMA_NAME(o.schema_id) IN ('dbo','hts','stage')
ORDER BY SCHEMA_NAME(o.schema_id), o.name;