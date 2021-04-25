SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_TRIGGER_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_TRIGGER_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_TRIGGER_IF_EXISTS]
(
	@v_Object_Name	SYSNAME	--Trigger Name
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
			@v_InternaltObjectID INT = NULL

	EXEC DBTD_SPLIT_FOUR_PART_OBJECT_NAME 
		@v_Object_Name, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_CorrectedName OUTPUT,
		@v_CorrectTempTablesLocation = 1;

	BEGIN TRY 
		EXEC DBO.DBTD_GET_OBJECT_ID @v_CorrectedName, @v_Object_ID = @v_InternaltObjectID OUTPUT;

		--IF  OBJECT_ID (@v_Object_Name, 'TR') IS NOT NULL --find if there is a trigger with such a name
		IF (@v_InternaltObjectID IS NOT NULL)
		BEGIN
			SET @v_SQL = 'DROP TRIGGER ' + ISNULL( @v_Schema + '.', '') + @v_Object;

			EXEC DBO.DBTD_SP_EXECUTESQL	@v_Database, @v_SQL
			
			SET @v_Message = 'Trigger "' + @v_CorrectedName + '" has been dropped in the ' + @v_Database + ' database.';
			PRINT @v_Message;
			RETURN 1; 
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot drop TRIGGER, object not found:  "' + @v_CorrectedName + '" ';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'Cannot drop "' + @v_CorrectedName + '" trigger. ' + ERROR_MESSAGE();
		PRINT @v_Message;
		RETURN 0; 
	END CATCH 
END;

GO
