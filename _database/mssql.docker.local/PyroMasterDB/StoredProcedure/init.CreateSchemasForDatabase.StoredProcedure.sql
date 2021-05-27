SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[init].[CreateSchemasForDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [init].[CreateSchemasForDatabase] AS' 
END
GO
-- Create Procedure CreateSchemasForDatabase
-- Create Procedure CreateSchemasForDatabase

-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Schema Creator for a database
/*
	EXEC [init].CreateSchemasForDatabase
*/

ALTER    PROCEDURE [init].[CreateSchemasForDatabase]
AS
    BEGIN

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'access';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'array';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'automate';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'azure';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'benchmark';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'bprac';
		
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'compare';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'connect';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'config';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'dba';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'dimension';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'dataprofile';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'dt';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'hierarchy';
			
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'generate';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'help';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'init';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'inout';
			
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'logger';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'measure';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'meta';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'mssql';
			
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'number';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'printer';

		-- Where refrence data is stored
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'reference';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'secure';

		-- templating engine
		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'pyro';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'schedule';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'string';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'stat';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'struct';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'template';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'test';

		EXEC [construct].[CreateSchemaIfNotExists]
			@SchemaName = 'tool';
END
GO
