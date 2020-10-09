SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF


CREATE VIEW [DMOD].[vw_sys_View]
AS

	SELECT 
		sm.[object_id] AS ObjectID
	,	v.[name] AS ViewName
	,	s.[schema_id] AS SchemaID
	,	s.[name] AS SchemaName
	,	o.[type] AS ObjectType
    ,	o.[type_desc] AS ObjectTypeDescription
	,	o.[create_date]  AS CreatedDT
	,	o.[modify_date] AS UpdatedDT
	,	OBJECT_DEFINITION(sm.[object_id]) AS ViewDefinition
	FROM 
		sys.objects AS o 
	INNER JOIN 
		sys.views AS v
		ON v.object_id = o.object_id
	INNER JOIN 
		sys.schemas AS s
		ON s.schema_id = v.schema_id
	INNER JOIN 
		sys.sql_modules AS sm  
		ON sm.object_id = o.object_id
	WHERE 
		o.[type] = 'V'

GO
