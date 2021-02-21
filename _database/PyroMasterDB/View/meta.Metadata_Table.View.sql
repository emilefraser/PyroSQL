SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Table]'))
EXEC dbo.sp_executesql @statement = N'
CREATE    VIEW [meta].[Metadata_Table]
AS
SELECT
	ObjectID								= obj.object_id
  , SchemaName								= sch.name
  , TableName								= tab.name
  , ObjectType								= obj.type
  , ObjectTypeDesription					= obj.type_desc
  ,	IsExternalTable							= tab.is_external
  , TemporalTableType						= tab.temporal_type
  , TemporalTableTypeDescription			= tab.temporal_type_desc
  , ColumnCount								= tab.max_column_id_used
  , CreatedDT								= tab.create_date
  , ModifiedDT								= tab.modify_date
FROM 
	sys.objects AS obj
INNER JOIN
	sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''




' 
GO
