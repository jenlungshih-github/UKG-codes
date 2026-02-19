SELECT
    s.name             AS SchemaName,
    t.name             AS TableName,
    FORMAT(SUM(p.rows), 'N0') AS RowCounts,
    SUM(a.total_pages) * 8    AS TotalKB,
    --SUM(a.used_pages)  * 8    AS UsedKB,
    --SUM(a.data_pages)  * 8    AS DataKB,
    CAST( (SUM(a.total_pages) * 8) / 1024.0 AS DECIMAL(12,2)) AS TotalMB
FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
    JOIN sys.allocation_units a ON a.container_id = p.partition_id
WHERE s.name = 'DataHub_Stage'
GROUP BY s.name, t.name
ORDER BY TotalKB DESC;