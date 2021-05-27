SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Column]'))
EXEC dbo.sp_executesql @statement = N'

CREATE    VIEW [meta].[Metadata_Column]
AS
SELECT 
	ObjectId			= tab.object_id,
	SchemaName			= schema_name(tab.schema_id),
    TableName			= tab.name, 
    ColumnId			= col.column_id,
    ColumnName			= col.name, 
    DataType			= typ.name,
    ColumnMaxLength		= col.max_length,
	ColumnScale			= col.scale,
    ColumnPrecision		= col.precision,
	IsNullable			= col.is_nullable,
	CreatedDT			= tab.create_date,
	ModifiedDT			= tab.modify_date
FROM 
	sys.tables as tab
INNER JOIN
	sys.columns as col
    ON tab.object_id = col.object_id
left join 
	sys.types as typ
    ON col.user_type_id = typ.user_type_id;
' 
GO
