SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Table_3]'))
EXEC dbo.sp_executesql @statement = N'

CREATE   VIEW [meta].[Metadata_Table_3]
AS
SELECT
	DatabaseName							= ''PyroMasterDB''
  , ObjectID								= obj.object_id
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
	[PyroMasterDB].sys.objects AS obj
INNER JOIN
	[PyroMasterDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroMasterDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

UNION ALL 

SELECT
	DatabaseName							= ''PyroLandingZoneDB''
  , ObjectID								= obj.object_id
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
	[PyroLandingZoneDB].sys.objects AS obj
INNER JOIN
	[PyroLandingZoneDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroLandingZoneDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

UNION ALL 

SELECT
	DatabaseName							= ''PyroSourceDB''
  , ObjectID								= obj.object_id
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
	[PyroSourceDB].sys.objects AS obj
INNER JOIN
	[PyroSourceDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroSourceDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

UNION ALL 

SELECT
	DatabaseName							= ''PyroCustomerDB''
  , ObjectID								= obj.object_id
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
	[PyroCustomerDB].sys.objects AS obj
INNER JOIN
	[PyroCustomerDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroCustomerDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

UNION ALL 

SELECT
	DatabaseName							= ''PyroModelDB''
  , ObjectID								= obj.object_id
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
	[PyroModelDB].sys.objects AS obj
INNER JOIN
	[PyroModelDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroModelDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

	
UNION ALL 

SELECT
	DatabaseName							= ''AdventureWorks''
  , ObjectID								= obj.object_id
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
	[AdventureWorks].sys.objects AS obj
INNER JOIN
	[AdventureWorks].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[AdventureWorks].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''

	
UNION ALL 

SELECT
	DatabaseName							= ''PyroV1''
  , ObjectID								= obj.object_id
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
	[PyroV1].sys.objects AS obj
INNER JOIN
	[PyroV1].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN
	[PyroV1].sys.schemas sch
	ON obj.schema_id = sch.schema_id
WHERE
	obj.type = ''U''


' 
GO
