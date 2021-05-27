SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Procedure]'))
EXEC dbo.sp_executesql @statement = N'
CREATE      VIEW [meta].[Metadata_Procedure]
AS
SELECT
	ObjectID	= obj.object_id
  , SchemaName	= SCHEMA_NAME(obj.schema_id)
  , ProcedureName = obj.name
  , ObjectType = obj.type
  , ObjectTypeDescription = CASE obj.type
		WHEN ''P''
			THEN
				''SQL Stored Procedure''
		WHEN ''X''
			THEN
				''Extended stored procedure''
	END
  , ObjectParameters = SUBSTRING(par.parameters, 0, LEN(par.parameters))
  , ObjectDefinition = mod.definition
  , CreatedDT = obj.create_date
  , ModifiedDT = obj.modify_date
FROM
	sys.objects obj
JOIN
	sys.sql_modules mod
	ON mod.object_id = obj.object_id
CROSS APPLY
	(
		SELECT p.name + '' '' + TYPE_NAME(p.user_type_id) + '', ''
		FROM
			sys.parameters p
		WHERE
			p.object_id = obj.object_id
			AND p.parameter_id != 0
		FOR XML PATH ('''')
	) par (parameters)
WHERE
	obj.type IN (''P'', ''X'');

' 
GO
