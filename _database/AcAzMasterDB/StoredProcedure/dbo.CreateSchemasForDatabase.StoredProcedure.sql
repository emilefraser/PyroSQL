SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CreateSchemasForDatabase]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[CreateSchemasForDatabase] AS' 
END
GO
-- Create By	:	Emile Fraser
-- Date			:	2021-01-02
-- Description	:	Schema Creator for a database
-- EXEC dbo.CreateSchemasForDatabase

ALTER PROCEDURE [dbo].[CreateSchemasForDatabase]
AS
    BEGIN
       
	   EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'access';
	   	   
	   EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'azure';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'bp';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'conn';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'dba';

		EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'dim';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'dyna';

		EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'inout';

		EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'meta';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'mssql';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'string';

        EXEC [dbo].[CreateSchemaIfNotExists] 
             @SchemaName = 'tool';
    END
GO
