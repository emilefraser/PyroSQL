SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- TEST
-- SELECT ##udf_Get_QualifiedObjectName('[Server]')
-- SELECT ##udf_Get_QualifiedObjectName('[Server].[Schema]')
-- SELECT ##udf_Get_QualifiedObjectName('[Server].Schema')
-- SELECT ##udf_Get_QualifiedObjectName('[Database].[Schema].[Table]')
-- SELECT ##udf_Get_QualifiedObjectName('[Database].[Schema]')
-- SELECT ##udf_Get_QualifiedObjectName('Schema.Table')
-- SELECT ##udf_Get_QualifiedObjectName('Schema.Table)
-- SELECT ##udf_Get_QualifiedObjectName('Schema.Table)
-- SELECT ##udf_Get_QualifiedObjectName('Server.Database.Schema.Table')
-- SELECT ##udf_Get_QualifiedObjectName('[Server].[Database].[Schema].[Table]')
CREATE OR ALTER  FUNCTION ##udf_Get_QualifiedObjectName
(
	@ObjectName SYSNAME
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
	WHERE type='P'

	SELECT definition 
	FROM sys.sql_modules 
	WHERE object_id = OBJECT_ID('yourSchemaName.yourStoredProcedureName')

	SELECT
		sch.name+'.'+ob.name AS       [Object], 
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
	WHERE object_id = object_id('uspGetAlbumsByArtist');

	EXEC sp_helptext 'uspGetAlbumsByArtist';



	SELECT ROUTINE_DEFINITION, *
	FROM INFORMATION_SCHEMA.ROUTINES
	WHERE ROUTINE_NAME = 'uspGetAlbumsByArtist';
	*/

	-- Return the result of the function
	RETURN @Object_Definition

END


CREATE OR ALTER PROCEDURE ##sp_Get_TestDataFromCustomerEnvironment (
    @ServerName_Source  SYSAME = NULL
,	@SchemaName_Source 
,	@DatabaseName_Source 

,	@DatabaseName_Source =

,	@IsTest  = 0
,	@IsDebug = 0
)


ALTER   PROCEDURE [TESTMASTER].[sp_Execute_ActualTestData]
AS
BEGIN

SELECT 'TODO'
/*
EXEC  [TESTMASTER].[sp_Get_ActualTestData]
	@ServerName_Source  = NULL
,	@SchemaName_Source 
,	@DatabaseName_Source 

,	@DatabaseName_Source =

,	@IsTest  = 0
,	@IsDebug = 0
*/
END
if on network
-- use linked server

-- powershell job


-- if not, export files from cloud to onedrive (including structures)

-- create on this side by consumign files

