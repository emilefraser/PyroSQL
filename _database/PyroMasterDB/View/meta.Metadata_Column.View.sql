SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Column]'))
EXEC dbo.sp_executesql @statement = N'
-- SELECT * FROM [meta].[Metadata_Column]

CREATE   VIEW [meta].[Metadata_Column]
AS
SELECT 
	DatabaseName		= ''PyroMasterDB''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroMasterDB].sys.objects AS obj
INNER JOIN
	[PyroMasterDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroMasterDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroMasterDB].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroMasterDB].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroSourceDB''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroSourceDB].sys.objects AS obj
INNER JOIN
	[PyroSourceDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroSourceDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroSourceDB].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroSourceDB].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroModelDB''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroModelDB].sys.objects AS obj
INNER JOIN
	[PyroModelDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroModelDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroModelDB].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroModelDB].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL


SELECT 
	DatabaseName		= ''PyroLandingZoneDB''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroLandingZoneDB].sys.objects AS obj
INNER JOIN
	[PyroLandingZoneDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroLandingZoneDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroLandingZoneDB].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroLandingZoneDB].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroCustomerDB''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroCustomerDB].sys.objects AS obj
INNER JOIN
	[PyroCustomerDB].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroCustomerDB].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroCustomerDB].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroCustomerDB].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL

SELECT 
	DatabaseName		= ''AdventureWorks''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[AdventureWorks].sys.objects AS obj
INNER JOIN
	[AdventureWorks].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[AdventureWorks].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[AdventureWorks].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[AdventureWorks].sys.types AS typ
    ON col.user_type_id = typ.user_type_id

UNION ALL

SELECT 
	DatabaseName		= ''PyroV1''
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	IsNullable			= col.is_nullable
,	IsComputed			= col.is_computed
,	IsIdentity			= col.is_identity
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	[PyroV1].sys.objects AS obj
INNER JOIN
	[PyroV1].sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	[PyroV1].sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	[PyroV1].sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	[PyroV1].sys.types AS typ
    ON col.user_type_id = typ.user_type_id














' 
GO
