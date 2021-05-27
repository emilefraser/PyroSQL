SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_GET_OBJECT_ID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_GET_OBJECT_ID] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_GET_OBJECT_ID]
(
	@v_Object_Name SYSNAME, --four part object name
	@v_Object_ID BIGINT OUTPUT
)
  AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_SQL NVARCHAR(MAX) = '',
			@v_Server NVARCHAR(2000),
			@v_Database NVARCHAR(2000),
			@v_Schema NVARCHAR(2000),
			@v_CorrectedName NVARCHAR(2000),
			@v_Object NVARCHAR(2000),
			@v_ParmDefinition NVARCHAR(MAX) = N'@v_InternaltObjectID INT OUTPUT'

	EXEC DBTD_SPLIT_FOUR_PART_OBJECT_NAME 
		@v_Object_Name, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_CorrectedName OUTPUT,
		@v_CorrectTempTablesLocation = 1;
	SET @v_Sql = 'SELECT @v_InternaltObjectID = OBJECT_ID ('''+@v_CorrectedName+'''); ';
	EXEC sp_executeSQL
		@v_Sql,
		@v_ParmDefinition,
		@v_InternaltObjectID = @v_Object_ID OUTPUT
END

GO
