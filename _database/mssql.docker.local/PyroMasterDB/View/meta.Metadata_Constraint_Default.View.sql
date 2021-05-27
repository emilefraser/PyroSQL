SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Constraint_Default]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [meta].[Metadata_Constraint_Default]
AS
     WITH special AS (
		SELECT
			crlf		= CHAR(13) + CHAR(10)
		,	tab			= CHAR(9)
		,	crlf2		= REPLICATE(CHAR(13) + CHAR(10), 2)
		,	crlf_tab	= CHAR(13) + CHAR(10) + CHAR(9)
		,	crlf_tab2	= CHAR(13) + CHAR(10) + REPLICATE(CHAR(9), 2)
		,	crlf2_tab	= REPLICATE(CHAR(13) + CHAR(10), 2) + CHAR(9)
		,	crlf2_tab2	= REPLICATE(CHAR(13) + CHAR(10), 2) + REPLICATE(CHAR(9), 2)
	), cte_Constraint_Default AS (
	SELECT 
		DefaultContraintObjectID	= defc.object_id
	,	DefaultContraintName		= defc.name
	,	SchemaName					= sch.name
	,	ObjectName					= OBJECT_NAME(defc.parent_object_id)
	,	ColumnName					= COL_NAME(defc.parent_object_id, defc.parent_column_id)
	,	ConstraintType				= defc.type
	,	ConstraintTypeDescription	= defc.type_desc
	,	ConstraintDefinition		= defc.definition
	,	IsSystemObject				= defc.is_ms_shipped
	,	IsSystemNamed				= defc.is_system_named
	,	CreatedDate					= obj.create_date
	,	ModifiedDate				= obj.modify_date
	FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = obj.schema_id
	INNER JOIN 
		sys.default_constraints AS defc
		ON obj.object_id = defc.object_id
	WHERE
		obj.type = ''D''
	)
	SELECT 
		DefaultContraintObjectID
	,	DefaultContraintName
	,	SchemaName
	,	ObjectName
	,	ColumnName
	,	ConstraintType
	,	ConstraintTypeDescription
	,	ConstraintDefinition
	,	IsSystemObject
	,	IsSystemNamed
	,	DDL_Create					= ''ALTER TABLE '' + QUOTENAME(SchemaName) + ''.'' + QUOTENAME(ObjectName) + spec.crlf + '' ADD CONSTRAINT '' + QUOTENAME(''DF_'' + SchemaName + ''_'' + ObjectName + ''_'' + ColumnName) + '' DEFAULT '' + ConstraintDefinition + '' FOR '' + QUOTENAME(ColumnName) + '';''
	,	DDL_Alter					= ''ALTER TABLE '' + QUOTENAME(SchemaName) + ''.'' + QUOTENAME(ObjectName) + '' ADD CONSTRAINT '' + QUOTENAME(''DF_'' + SchemaName + ''_'' + ObjectName + ''_'' + ColumnName) + '';''
	,	DDL_Drop					= ''ALTER TABLE '' + QUOTENAME(SchemaName) + ''.'' + QUOTENAME(ObjectName) + '' DROP CONSTRAINT IF EXISTS '' + QUOTENAME(DefaultContraintName) + '';''
	,	CreatedDate
	,	ModifiedDate
	FROM 
		cte_Constraint_Default AS condef
	CROSS JOIN 
		special AS spec
' 
GO
