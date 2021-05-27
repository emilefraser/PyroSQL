SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[udf_Get_ObjectDefinition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
-- TEST
-- SELECT PERFTEST.udf_Get_ObjectDefinition(''[PERFTEST].[sp_Create_MetricsLog]'', ''P'')
-- SELECT PERFTEST.udf_Get_ObjectDefinition(''[PERFTEST].[sp_Create_MetricsLog]'', ''SQL_STORED_PROCEDURE'')
-- SELECT PERFTEST.udf_Get_ObjectDefinition(''[PERFTEST].[sp_Create_MetricsLog]'', NULL)
-- SELECT PERFTEST.udf_Get_ObjectDefinition(''[PERFTEST].[sp_Create_MetricsLog]'', '''')
-- SELECT PARSENAME(''[PERFTEST].[sp_Create_MetricsLog]'', 1)
CREATE   FUNCTION [meta].[udf_Get_ObjectDefinition]
(
	@ObjectName SYSNAME
,	@ObjectType VARCHAR(128) = NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Object_Definition VARCHAR(MAX)

	-- Declare the return variable here
	IF(@ObjectType IS NULL OR LEN(@ObjectType) = 0)
	BEGIN
		SET @Object_Definition = (SELECT OBJECT_DEFINITION (OBJECT_ID(@ObjectName)))
	END

	ELSE
	BEGIN
		IF(LEN(@ObjectType) <=2 )
		BEGIN
			SET @Object_Definition = (
				SELECT 
					object_definition(o.object_id)
				FROM 
					sys.objects AS o
				WHERE 
					o.type = @ObjectType
				AND
					o.name = PARSENAME(@ObjectName, 1)
			)
		END

		ELSE
		BEGIN
			SET @Object_Definition = (
				SELECT 
					object_definition(o.object_id)
				FROM 
					sys.objects AS o
				WHERE 
					o.type_desc = @ObjectType
				AND
					o.name = PARSENAME(@ObjectName, 1)
				)
		END
	END



	-- Add the T-SQL statements to compute the return value here
	/*
	SELECT object_definition(object_id) as [Proc Definition]
	FROM sys.objects 
	WHERE type=''P''

	SELECT definition 
	FROM sys.sql_modules 
	WHERE object_id = OBJECT_ID(''yourSchemaName.yourStoredProcedureName'')

	SELECT
		sch.name+''.''+ob.name AS       [Object], 
		ob.create_date, 
		ob.modify_date, 
		ob.type_desc, 
		mod.definition
	FROM 
     sys.objects AS ob
     LEFT JOIN sys.schemas AS sch ON
            sch.schema_id = ob.schema_id
     LEFT JOIN sys.sql_modules AS mod ON
            mod.object_id = ob.object_id
	WHERE mod.definition IS NOT NULL --Selects only objects with the definition (code)
	
	SELECT definition
	FROM sys.sql_modules
	WHERE object_id = object_id(''uspGetAlbumsByArtist'');

	EXEC sp_helptext ''uspGetAlbumsByArtist'';



	SELECT ROUTINE_DEFINITION, *
	FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINE_NAME = ''uspGetAlbumsByArtist'';
	*/

	-- Return the result of the function
	RETURN @Object_Definition

END

' 
END
GO
