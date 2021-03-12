SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Object_Table]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [meta].[Object_Table]
AS
	SELECT   
		[DatabaseId]					= DB_ID()
	  ,	[DatabaseName]					= DB_NAME()
	  , [ObjectID]						= obj.object_id
	  , [SchemaId]						= sch.schema_id
	  , [SchemaName]					= [sch].[name]
	  , [TableName]						= [tab].[name]
	  , [ObjectTypeName]				= IIF([obj].[type_desc] = ''USER_TABLE'', ''TABLE'', [obj].[type_desc])
	  , [ColumnCount]					= [tab].[max_column_id_used]
	  , [IsSystemObject]				= [obj].[is_ms_shipped]
	  ,	[IsExternalTable]				= [tab].[is_external]
	  , [IsTemporalTable]				= IIF([tab].[temporal_type] != 0, 1, 0)
	  , [TemporalTableType]				= [tab].[temporal_type]
	  , [TemporalTableTypeName]			= [tab].[temporal_type_desc]
	  , [IsHistoryTable]				= IIF([tab].[temporal_type_desc] = ''HISTORY_TABLE'', 1, 0)
	  , [HistoryTableId]				= [tab].[history_table_id]
	  , [HistoryTableName]				= [tab_hist].[name]
	  ,	[HistoryTableSchemaId]			= SCHEMA_ID(OBJECT_SCHEMA_NAME([tab].[history_table_id]))
	  ,	[HistoryTableSchemaName]		= OBJECT_SCHEMA_NAME([tab].[history_table_id])
	  ,	[ObjectType]					= ''U''
	  ,	[ObjectClass]					= ''DAT''
	  , [CreatedDT]						= [tab].[create_date]
	  , [ModifiedDT]					= [tab].[modify_date]
	FROM   
		[sys].[objects] AS [obj]
	INNER JOIN
		[sys].[tables] AS [tab]
		ON [tab].object_id = [obj].object_id
	INNER JOIN
		[sys].[schemas] [sch]
		ON [obj].schema_id = [sch].schema_id
	LEFT JOIN 
		[sys].[tables] AS [tab_hist]
		ON [tab_hist].[object_id] = [tab].[history_table_id]
	WHERE 
		[obj].[type] = ''U'';

' 
GO
