SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_DROP_FULLTEXT_INDEX_IF_EXISTS]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_DROP_FULLTEXT_INDEX_IF_EXISTS] AS' 
END
GO

--************************************************************************************************
ALTER PROCEDURE [construct].[DBTD_DROP_FULLTEXT_INDEX_IF_EXISTS]
(
	@v_Object_Name	SYSNAME --Name of a table or indexed view for which full text index need to be removed
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
			@v_InternaltObjectID INT = NULL,
			@v_HadError BIT = 0

	CREATE TABLE #DBTD_TablesWithFullTextIndex(
		ObjectName NVARCHAR(128)
	)

	EXEC DBTD_SPLIT_FOUR_PART_OBJECT_NAME  
		@v_Object_Name, 
		@v_Server = @v_Server OUTPUT, @v_Database = @v_Database OUTPUT, @v_Schema = @v_Schema OUTPUT, 
		@v_Object = @v_Object OUTPUT, @v_CorrectedName = @v_CorrectedName OUTPUT,
		@v_CorrectTempTablesLocation = 1;

	BEGIN TRY 
		EXEC DBO.DBTD_GET_OBJECT_ID @v_CorrectedName, @v_Object_ID = @v_InternaltObjectID OUTPUT;
		IF (@v_InternaltObjectID IS NOT NULL)
		BEGIN
			SET @v_SQL = 
				'INSERT INTO #DBTD_TablesWithFullTextIndex
					(ObjectName)
					SELECT ''' + LTRIM(RTRIM(@v_Database)) + '.['' + s.name + ''].['' + o.name + '']''
					FROM ' + LTRIM(RTRIM(@v_Database)) + '.sys.fulltext_indexes AS i
						INNER JOIN ' + LTRIM(RTRIM(@v_Database)) + '.sys.objects AS o
							ON i.object_id = o.object_id
						INNER JOIN DBTestDriven.sys.schemas AS S
							ON o.schema_id = s.schema_id
					WHERE o.name = ''' + REPLACE(REPLACE(@v_Object,'[',''),']','') + '''
						AND s.name = ''' + REPLACE(REPLACE(@v_Schema,'[',''),']','') + ''';'
			EXEC DBTD_SP_EXECUTESQL @v_Database, @v_SQL
			IF EXISTS( SELECT 1 FROM #DBTD_TablesWithFullTextIndex )
			BEGIN
				SET @v_SQL = 'DROP FULLTEXT INDEX ON ' + @v_CorrectedName;
				EXEC DBO.DBTD_SP_EXECUTESQL	@v_Database, @v_SQL
				SET @v_Message = 'FULL TEXT index has been dropped from [' + @v_CorrectedName +  '] object.';
				PRINT @v_Message;
				RETURN 1; 
			END 
			ELSE BEGIN 
				SET @v_Message = 'Cannot drop FULL TEXT index, object not found [' + @v_CorrectedName +  '] object.';
				PRINT @v_Message;
				RETURN 0; 
			END
		END
		ELSE BEGIN 
			SET @v_Message = 'Cannot drop INDEX, object not found: [' + @v_CorrectedName +  ']';
			PRINT @v_Message;
			RETURN 0; 
		END; 
	END TRY
	BEGIN CATCH
		SET @v_Message = 'ERROR!!! Cannot drop FULL TEXT index created for ' + @v_CorrectedName +  ' object. ' + ERROR_MESSAGE();
		PRINT @v_Message;
		SET @v_HadError = 1
		--check if we are within DBTD_RUNONETEST_EXT and if not then just exit
		IF OBJECT_ID('tempdb.dbo.#DBTD_RunningNowUnitTest') IS NULL 
		BEGIN
			RETURN 0; 
		END
	END CATCH 
	/*
	TODO: remove this code, it does not belong here
	--and now lets see if we had error to flash back so that unit test will fail because full text index cannot be dropped 
	--under transaction
	IF OBJECT_ID('tempdb.dbo.#DBTD_RunningNowUnitTest') IS NOT NULL 
		AND @v_HadError = 1
		AND OBJECT_ID('DBTD_FAILURE') IS NOT NULL 
		AND @@TRANCOUNT > 0
	BEGIN
		--TODO: failing in the tools might not be an option...
		--      review the code one more time and make sure that it does not cross single responcibility rules
		EXEC DBTD_FAILURE @v_Message
	END
	*/
END;

GO
