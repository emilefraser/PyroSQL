SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[init].[CreateDatabaseAndDeployArtefact]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [init].[CreateDatabaseAndDeployArtefact] AS' 
END
GO
-- Create Procedure CreateSchemasForDatabase

-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Deployes Core items to a new database
/*
EXEC	[init].[CreateDatabaseAndDeployArtefact]
					@DatabaseName		= 'VaultSpeed'
				,	@DatabaseCategory	= 'Model'
				,	@ArtefactTypeList   = NULL
*/

ALTER   PROCEDURE [init].[CreateDatabaseAndDeployArtefact]
	@DatabaseName			SYSNAME
,	@DatabaseCategory		SYSNAME
,	@ArtefactTypeList		NVARCHAR(MAX) = NULL
AS
    BEGIN

	DECLARE @sql_statement NVARCHAR(MAX)

		---- Create the Database
		--EXEC [construct].[CreateDatabaseIfNotExist]
		--		@DatabaseName		= @DatabaseName
		--	,	@RootFolder			= 'D:\Database\localdb'
		--	,	@Category			= @DatabaseCategory

		-- Create an Init Schema (ALWAYS)


	--	EXEC [construct].[CreateSchemaIfNotExists]
	--	@SchemaName = 'access';
	--EXEC('USE Vaultspeed')
	SET @sql_statement = 'USE ' + QUOTENAME(@DatabaseName) + ' CREATE SCHEMA initalize;'
	EXEC sp_executesql 
				@stmt = @sql_statement



END
GO
