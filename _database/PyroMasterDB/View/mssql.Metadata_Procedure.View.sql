SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[mssql].[Metadata_Procedure]'))
EXEC dbo.sp_executesql @statement = N'
-- SELECT * FROM [mssql].[Metadata_Procedure]

CREATE       VIEW [mssql].[Metadata_Procedure]
AS
SELECT
	ObjectID				= aobj.object_id
  , SchemaName				= SCHEMA_NAME(aobj.schema_id)
  , ProcedureName			= aobj.name
  , ObjectType				= aobj.type
  , ObjectTypeDescription	= CASE aobj.type
									WHEN ''P''
										THEN
											''SQL Stored Procedure''
									WHEN ''X''
										THEN
											''Extended stored procedure''
								END
  , ObjectParameters		= SUBSTRING(par.all_parameters, 0, LEN(par.all_parameters))
  , ObjectDefinition		= asmod.definition
  , CreatedDT				= aobj.create_date
  , ModifiedDT				= aobj.modify_date
FROM
	sys.all_objects AS aobj
JOIN
	sys.all_sql_modules AS asmod
	ON asmod.object_id = aobj.object_id
CROSS APPLY
	(
		SELECT apar.name + '' '' + TYPE_NAME(apar.user_type_id) + '', ''
		FROM
			sys.all_parameters AS apar
		WHERE
			apar.object_id = aobj.object_id
			AND apar.parameter_id != 0
		FOR XML PATH ('''')
	) par (all_parameters)
WHERE
	aobj.type IN (''P'', ''X'');

' 
GO
