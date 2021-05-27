SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_INDEX_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_INDEX_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_INDEX_IF_EXISTS]
(
	@v_Index_Name	SYSNAME,	--Index Name
	@v_Object_Name	SYSNAME		--Object name (Table or View)
)
  AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_SQL NVARCHAR(MAX) = '',
			@v_Message VARCHAR(2000),
			@v_Server NVARCHAR(2000),
			@v_Database NVARCHAR(2000),
			@v_Schema NVARCHAR(2000),
			@v_CorrectedName NVARCHAR(2000),
			@v_Object NVARCHAR(2000),
			@v_Object_ID INT = NULL,
			@v_ParmDefinition NVARCHAR(MAX) = N' @v_InternalIndexID INT OUTPUT, @v_Index_Name NVARCHAR(255), @v_Object_ID INT ',
			@v_InternalIndexID INT


	EXEC DBTD_SPLIT_FOUR_PART_OBJECT_NAME 
		@v_Object_Name, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_CorrectedName OUTPUT,
		@v_CorrectTempTablesLocation = 1;

	BEGIN TRY 
		EXEC DBO.DBTD_GET_OBJECT_ID @v_CorrectedName, @v_Object_ID = @v_Object_ID OUTPUT;

		SET @v_SQL = ' SELECT @v_InternalIndexID = I.index_id FROM ' +@v_Database+ '.SYS.INDEXES AS I INNER JOIN '+@v_Database+'.dbo.SYSOBJECTS AS O ON I.object_ID = O.ID
				    WHERE UPPER(I.NAME) = LTRIM(RTRIM(UPPER(@v_Index_Name))) AND O.id = @v_Object_ID '
		EXECUTE sp_executeSQL
				@v_Sql,
				@v_ParmDefinition,
				@v_InternalIndexID = @v_InternalIndexID OUTPUT,
				@v_Index_Name = @v_Index_Name,
				@v_Object_ID = @v_Object_ID

		IF (@v_InternalIndexID IS NOT NULL)
		BEGIN
			SET @v_SQL = 'DROP INDEX ' + @v_Index_Name + ' ON ' + @v_Object_Name;
			EXECUTE sp_executesql @v_SQL;
			SET @v_Message = 'Index [' + @v_Index_Name + '] has been dropped for ['+@v_Object_Name+'] object.';
			PRINT @v_Message;
			RETURN 1; 
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot find index [' + @v_Index_Name + '] that belongs to ['+@v_Object_Name+'] object.';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'Cannot drop [' + @v_Index_Name + '] index that belongs to ['+@v_Object_Name+'] object. ' + ERROR_MESSAGE();
		PRINT @v_Message;
		RETURN 0; 
	END CATCH 
END;

GO
