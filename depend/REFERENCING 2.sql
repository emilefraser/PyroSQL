SELECT
SCHEMA_NAME(o.[schema_id])
, o.name
, d.referenced_database_name
, d.referenced_schema_name
, d.referenced_entity_name
FROM sys.sql_expression_dependencies d
JOIN sys.objects o ON d.referencing_id = o.[object_id]
WHERE d.is_ambiguous = 0
AND d.referenced_id IS NULL
AND d.referenced_server_name IS NULL
AND CASE d.referenced_class
WHEN 1
THEN OBJECT_ID(
ISNULL(QUOTENAME(d.referenced_database_name), DB_NAME()) + '.' +
ISNULL(QUOTENAME(d.referenced_schema_name), SCHEMA_NAME()) + '.' +
QUOTENAME(d.referenced_entity_name))
WHEN 6
THEN TYPE_ID(
ISNULL(d.referenced_schema_name, SCHEMA_NAME()) + '.' + d.referenced_entity_name)

WHEN 10
THEN (
SELECT 1 FROM sys.xml_schema_collections x
WHERE x.name = d.referenced_entity_name
AND x.[schema_id] = ISNULL(SCHEMA_ID(d.referenced_schema_name), SCHEMA_ID())
)
END IS NULL



SET NOCOUNT ON;
DECLARE @obj_id INT = OBJECT_ID('raw.HUB_GoodReceiptLine');
IF OBJECT_ID('tempdb.dbo.#h') IS NOT NULL DROP TABLE #h
CREATE TABLE #h (
obj_id INT NULL
, obj_name SYSNAME
, obj_schema SYSNAME NULL
, obj_type CHAR(5) NULL
);
INSERT INTO #h
SELECT
s.referencing_id
, COALESCE(t.name, o.name)
, SCHEMA_NAME(o.[schema_id])
, CASE s.referencing_class
WHEN 1THEN o.[type]
WHEN 7THEN 'U'
WHEN 9THEN 'U'
WHEN 12 THEN 'DDLTR'
END
FROM sys.sql_expression_dependencies s
LEFT JOIN sys.objects o ON o.[object_id] = s.referencing_id
AND o.[type] NOT IN ('D', 'C')
LEFT JOIN sys.triggers t ON t.[object_id] = s.referencing_id
AND t.parent_class = 0
AND s.referencing_class = 12
WHERE (o.[object_id] IS NOT NULL OR t.[object_id] IS NOT NULL)
AND s.referenced_server_name IS NULL
AND (
(s.referenced_id IS NOT NULL AND s.referenced_id = @obj_id)
OR
(s.referenced_id IS NULL
AND OBJECT_ID(
QUOTENAME(ISNULL(s.referenced_schema_name, SCHEMA_NAME())) + '.' +
QUOTENAME(s.referenced_entity_name)
) = @obj_id)
)

SELECT * FROM tempdb.dbo.#h
