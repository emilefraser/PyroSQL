SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Function]'))
EXEC dbo.sp_executesql @statement = N'
/***meta***
	SELECT * FROM [meta].[Metadata_Function]
***meta***/
CREATE   VIEW [meta].[Metadata_Function]
AS
SELECT
	SchemaName					= SCHEMA_NAME(obj.schema_id)
  , FunctionName				= obj.name
  , ObjectType					= obj.type
  , ObjectTypeDescription		= CASE obj.type
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
  , ObjectParameter				= SUBSTRING(par.parameters, 0, LEN(par.parameters))
  , ReturnType					= TYPE_NAME(ret.user_type_id)
  , ObjectDefinition			= smod.definition
FROM
	sys.objects obj
JOIN
	sys.sql_modules smod
	ON smod.object_id = obj.object_id
CROSS APPLY (
	SELECT 
		p.name + '' '' + TYPE_NAME(p.user_type_id) + '', ''
	FROM
		sys.parameters p
	WHERE
		p.object_id = obj.object_id
		AND p.parameter_id != 0
	FOR XML PATH ('''')
) par (parameters)
LEFT JOIN
	sys.parameters ret
	ON  obj.object_id = ret.object_id
	AND ret.parameter_id = 0
WHERE
	obj.type IN (''FN'', ''TF'', ''IF'');
' 
GO
