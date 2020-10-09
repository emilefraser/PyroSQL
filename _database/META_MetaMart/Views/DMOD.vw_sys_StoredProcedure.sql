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
	FROM 
		sys.procedures AS p
	INNER JOIN
		sys.schemas AS s
	ON 
		s.schema_id = p.schema_id

GO
