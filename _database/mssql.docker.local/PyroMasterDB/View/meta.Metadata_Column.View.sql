SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Column]'))
EXEC dbo.sp_executesql @statement = N'

CREATE    VIEW [meta].[Metadata_Column]
AS
SELECT 
	DatabaseId			= DB_ID()
,	DatabaseName		= DB_NAME()
,	ObjectId			= obj.object_id
,	SchemaId			= obj.schema_id
,	SchemaName			= sch.name
,	TableId				= tab.object_id
,   TableName			= tab.name
,   ColumnId			= col.column_id
,   ColumnName			= col.name
,	DataTypeId			= col.system_type_id
,   DataType			= typ.name
,   ColumnMaxLength		= col.max_length
,	ColumnScale			= col.scale
,   ColumnPrecision		= col.precision
,	ComputeDefinition	= com.definition
,	CollationName		= col.collation_name
,	IsComputed			= col.is_computed
,	IsAnsiPadded		= col.is_ansi_padded
,	IsHidden			= col.is_hidden
,	IsIdentity			= col.is_identity
,	IsMasked			= col.is_masked
,	IsNullable			= col.is_nullable
,	CreatedDT			= tab.create_date
,	ModifiedDT			= tab.modify_date
FROM 
	sys.objects AS obj
INNER JOIN
	sys.schemas sch
	ON obj.schema_id = sch.schema_id
INNER JOIN 
	sys.tables AS tab
	ON tab.object_id = obj.object_id
INNER JOIN 
	sys.columns AS col
    ON tab.object_id = col.object_id
INNER JOIN
	sys.types AS typ
    ON col.user_type_id = typ.user_type_id
LEFT JOIN
	sys.computed_columns com
	ON com.object_id = obj.object_id
' 
GO
