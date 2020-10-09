SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF



CREATE VIEW [DMOD].[vw_sys_Table]
AS

	SELECT 
		o.[object_id] AS ObjectID
	,	t.[name] AS TableName
	,	s.[schema_id] AS SchemaID
	,	s.[name] AS SchemaName
	,	o.[type] AS ObjectType
    ,	o.[type_desc] AS ObjectTypeDescription
	,   t.[is_schema_published] AS IsSchemaBound
	,	t.[temporal_type] AS TemporalType
	,	t.[temporal_type_desc] AS TemporalTypeDescription
	,	t.[is_external] AS IsExternal
	,	t.[is_edge] AS IsEdge
	,	o.[create_date]  AS CreatedDT
	,	o.[modify_date] AS UpdatedDT
	,	t.max_column_id_used AS TotalColumns
	FROM 
		sys.objects AS o 
	INNER JOIN 
		sys.tables AS t
		ON t.object_id = o.object_id
	INNER JOIN 
		sys.schemas AS s
		ON s.schema_id = t.schema_id
	WHERE 
		o.[type] = 'U'

GO
