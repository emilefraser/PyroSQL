SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF

CREATE VIEW [DMOD].[vw_sys_Function_TableValued]
AS

	SELECT 
		sm.[object_id] AS ObjectID
	,	o.[name] AS FunctionName
	,	s.[schema_id] AS SchemaID
	,	s.[name] AS SchemaName
	,	o.[type] AS ObjectType
    ,	o.[type_desc] AS ObjectTypeDescription
	,	o.[create_date]  AS CreatedDT
	,	o.[modify_date] AS UpdatedDT
	,	OBJECT_DEFINITION(sm.[object_id]) AS FunctionDefinition
	FROM 
		sys.sql_modules AS sm  
	INNER JOIN 
		sys.objects AS o 
		ON sm.[object_id] = o.[object_id] 
	INNER JOIN 
		sys.schemas AS s
		ON s.[schema_id] = o.[schema_id]
	WHERE 
		o.[type] = 'TF'

GO
