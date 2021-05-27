SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_PROC_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_PROC_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_PROC_IF_EXISTS]
(
	@v_Object_Name	SYSNAME,			-- Procedure name
	@v_Signature	VARCHAR(128) = ''	-- Reserved
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

	EXEC dbo.DBTD_SPLIT_FOUR_PART_OBJECT_NAME 
		@v_Object_Name, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_CorrectedName OUTPUT,
		@v_CorrectTempTablesLocation = 1;
	 
	BEGIN TRY 
		EXEC DBO.DBTD_GET_OBJECT_ID @v_CorrectedName, @v_Object_ID = @v_InternaltObjectID OUTPUT;

		IF (@v_InternaltObjectID IS NOT NULL)
		BEGIN
			SET @v_SQL = 'DROP PROCEDURE ' + ISNULL( @v_Schema + '.', '') + @v_Object;

			EXEC DBO.DBTD_SP_EXECUTESQL	@v_Database, @v_SQL

			SET @v_Message = 'Stored Procedure "' + @v_CorrectedName + '" has been dropped from ' + @v_Database + ' database.';
			PRINT @v_Message;
			RETURN 1; 
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot drop PROCEDURE, object not found: "' + @v_Object_Name + '"';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'Cannot drop "' + @v_Object_Name + '" procedure. ' + ERROR_MESSAGE();
		PRINT @v_Message;
		RETURN 0; 
	END CATCH 
END;

GO
