SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[init].[CreateSchemasForDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [init].[CreateSchemasForDatabase] AS' 
END
GO

-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Schema Creator for a database
/*
	EXEC [init].CreateSchemasForDatabase
*/

ALTER    PROCEDURE [init].[CreateSchemasForDatabase]
AS
    BEGIN

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'access';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'array';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'azure';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'benchmark';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'bprac';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'benchmark';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'connect';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'dba';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'dimension';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'dataprofile';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'dt';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'generate';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'init';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'inout';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'meta';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'mssql';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'number';

		-- Where refrence data is stored
		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'reference';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'secure';

		-- templating engine
		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'pyro';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'string';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'stat';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'struct';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'template';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'test';

		EXEC [tool].[CreateSchemaIfNotExists]
			@SchemaName = 'tool';
END
GO
