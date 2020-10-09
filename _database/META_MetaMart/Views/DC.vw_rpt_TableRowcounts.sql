SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_rpt_TableRowcounts] AS
select 1 test/*
SELECT 'DataVault' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [DataVault].sys.tables t 
		INNER JOIN [DataVault].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [DataVault].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [DataVault].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'DEV_DataVault' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [DEV_DataVault].sys.tables t 
		INNER JOIN [DEV_DataVault].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [DEV_DataVault].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [DEV_DataVault].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'StageArea' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (	
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [StageArea].sys.tables t 
		INNER JOIN [StageArea].sys.schemas s
			ON t.schema_id = s.schema_id 
		WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [StageArea].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [StageArea].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'DEV_StageArea' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [DEV_StageArea].sys.tables t 
		INNER JOIN [DEV_StageArea].sys.schemas s 
			ON t.schema_id = s.schema_id 
		WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [DEV_StageArea].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [DEV_StageArea].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'ODS_EMS' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [ODS_EMS].sys.tables t 
		INNER JOIN [ODS_EMS].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [ODS_EMS].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [ODS_EMS].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'DEV_ODS_EMS' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [DEV_ODS_EMS].sys.tables t 
		INNER JOIN [DEV_ODS_EMS].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [DEV_ODS_EMS].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [DEV_ODS_EMS].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'DEV_ODS_D365' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [DEV_ODS_D365].sys.tables t 
		INNER JOIN [DEV_ODS_D365].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
	) AS TBL
INNER JOIN [DEV_ODS_D365].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [DEV_ODS_D365].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]

UNION ALL

SELECT 'ODS_D365' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount
FROM (
		SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id 
		FROM [ODS_D365].sys.tables t 
		INNER JOIN [ODS_D365].sys.schemas s 
			ON t.schema_id = s.schema_id WHERE t.[type] = 'U'
) AS TBL
INNER JOIN [ODS_D365].sys.partitions AS PART	
	ON TBL.object_id = PART.object_id 
INNER JOIN [ODS_D365].sys.indexes AS IDX		
	ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id 
WHERE IDX.index_id < 2
GROUP BY TBL.SchemaName, TBL.[name]
*/

GO
