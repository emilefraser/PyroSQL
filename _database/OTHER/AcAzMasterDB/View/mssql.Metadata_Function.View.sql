SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[mssql].[Metadata_Function]'))
EXEC dbo.sp_executesql @statement = N'
/*
	SELECT * FROM [mssql].[Metadata_Function]
*/
CREATE      VIEW [mssql].[Metadata_Function]
AS
SELECT
	SchemaName					= SCHEMA_NAME(aobj.schema_id)
  , FunctionName				= aobj.name
  , ObjectType					= aobj.type
  , ObjectTypeDescription		= CASE aobj.type
										WHEN ''FN''
											THEN
												''SQL scalar function''
										WHEN ''TF''
											THEN
												''SQL inline table-valued function''
										WHEN ''IF''
											THEN
												''SQL table-valued-function''
									END
  , ObjectParameter				= SUBSTRING(par.all_parameters, 0, LEN(par.all_parameters))
  , ReturnType					= TYPE_NAME(aret.user_type_id)
  , ObjectDefinition			= asmod.definition
FROM
	sys.all_objects AS aobj
JOIN
	sys.all_sql_modules AS asmod
	ON asmod.object_id = aobj.object_id
CROSS APPLY (
	SELECT 
		apar.name + '' '' + TYPE_NAME(apar.user_type_id) + '', ''
	FROM
		sys.all_parameters AS apar
	WHERE
		apar.object_id = aobj.object_id
		AND apar.parameter_id != 0
	FOR XML PATH ('''')
) par (all_parameters)
LEFT JOIN
	sys.all_parameters AS aret
	ON  aobj.object_id = aret.object_id
	AND aret.parameter_id = 0
WHERE
	aobj.type IN (''FN'', ''TF'', ''IF'');
' 
GO
