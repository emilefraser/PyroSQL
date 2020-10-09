SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF




CREATE VIEW [DMOD].[vw_sys_StoredProcedure]
AS

	SELECT 
		p.[object_id] AS [ObjectID]
	,	p.[name] AS [ProcedureName]
	,	p.[schema_id] AS [SchemaID]
	,	s.[name] AS [SchemaName]
	,	p.[type] AS [TypeCode]
	,	p.[type_desc] AS [TypeDescription]
	,	p.create_date AS [CreatedDT]
	,	p.modify_date AS [UpdatedDT]
	,	OBJECT_DEFINITION(p.[object_id]) AS [ProcedureDefinition]
	,	LEN(OBJECT_DEFINITION(p.[object_id]))- LEN(REPLACE(OBJECT_DEFINITION(p.[object_id]),CHAR(10),'')) AS LinesOfCode
	FROM 
		sys.objects AS o
	INNER JOIN 
		sys.procedures AS p
		ON p.object_id = o.object_id
	INNER JOIN
		sys.schemas AS s
	ON 
		s.schema_id = p.schema_id
	INNER JOIN
		sys.sql_modules AS sm
		ON sm.object_id = o.object_id
	WHERE
		o.type = 'P'
	AND
		o.[is_ms_shipped] = 0

GO
