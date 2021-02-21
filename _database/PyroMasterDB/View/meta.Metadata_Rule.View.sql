SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Rule]'))
EXEC dbo.sp_executesql @statement = N'CREATE   VIEW [meta].[Metadata_Rule]
AS
     SELECT 
		ObjectID			= obj.object_id
	,   SchemaName			= sch.name
	,	ObjectName			= obj.name
    ,   RuleName			= obj.name
    ,   SqlType				= obj.type
	,	SqlTypeDescription	= obj.type_desc
	,	CreatedDT			= obj.create_date
	,	ModifiedDT			= obj.modify_date
     FROM 
		sys.objects AS obj
	INNER JOIN 
		sys.schemas AS sch
		ON sch.schema_id = obj.schema_id
	WHERE
		obj.type = ''R''
' 
GO
