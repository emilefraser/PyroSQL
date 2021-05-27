SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_SCHEMA_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_SCHEMA_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_SCHEMA_IF_EXISTS]
(
	@v_Object_Name	SYSNAME,
	@v_Database_Name NVARCHAR(128) = NULL --When null is specified then schema will be removed in the current context
)
  AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @v_SQL NVARCHAR(255),
			@v_Message VARCHAR(2000),
			@v_InternalSchemaID INT = NULL,
			@v_ParmDefinition NVARCHAR(MAX) = N' @v_InternalSchemaID INT OUTPUT, @v_Object_Name NVARCHAR(255) '
	
	IF (LTRIM(RTRIM(@v_Database_Name)) = '') SET @v_Database_Name = DB_NAME();
	IF (@v_Database_Name IS NULL) SET @v_Database_Name = DB_NAME();

	BEGIN TRY 
		SET @v_SQL = ' SELECT @v_InternalSchemaID = schema_id FROM ' + @v_Database_Name + '.SYS.SCHEMAS WHERE NAME = UPPER(@v_Object_Name) '
		EXECUTE sp_executeSQL
				@v_Sql,
				@v_ParmDefinition,
				@v_InternalSchemaID = @v_InternalSchemaID OUTPUT,
				@v_Object_Name = @v_Object_Name

		IF (@v_InternalSchemaID IS NOT NULL)
		BEGIN
			SET @v_SQL = 'DROP SCHEMA ' + @v_Object_Name;

			EXEC DBO.DBTD_SP_EXECUTESQL	@v_Database_Name, @v_SQL

			SET @v_Message = 'Schema "' + @v_Object_Name + '" has been dropped from [' + @v_Database_Name + '] database.';
			PRINT @v_Message;
			RETURN 1; 
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot drop SCHEMA, object not found:  "' + @v_Object_Name + '" schema in the [' + @v_Database_Name + '] database.';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'ERROR!!! Cannot drop "' + @v_Object_Name + '" schema. ' + ERROR_MESSAGE();
		PRINT @v_Message;
		RETURN 0; 
	END CATCH 
END;

GO
