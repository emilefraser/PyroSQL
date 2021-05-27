SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_SPLIT_FOUR_PART_OBJECT_NAME]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_SPLIT_FOUR_PART_OBJECT_NAME] AS' 
END
GO

--************************************************************************************************
--Function separates a v_Name string lile 'server.database.schema.object' into four distinct 
--object name parts: server, database, schema and object.
--NOTE: if @v_CorrectTempTablesLocation set to 1, procedure will:
--             - correct temp table location to be server.TEMPDB.dbo.#temptable, DEFAULT value is 1 
--             - uses DBO as default schema 
--INTERNAL: Do not use this function in your unit tests, procedure can be removed,
--          signature or procedure name can be changed at any release
ALTER PROCEDURE [construct].[DBTD_SPLIT_FOUR_PART_OBJECT_NAME]
(
	@v_Name		SYSNAME,				-- Fully qualified SQL name
	@v_Server	NVARCHAR(128) OUTPUT,
	@v_Database NVARCHAR(128) OUTPUT,
	@v_Schema	NVARCHAR(128) OUTPUT,
	@v_Object	NVARCHAR(128) OUTPUT,
	@v_CorrectedName SYSNAME OUTPUT,	
	@v_CorrectTempTablesLocation BIT = 1
)
  
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_TmpStr VARCHAR(2000),
			@v_Separator CHAR(1) = '.',
			@v_NumberOfParts INT,
			@v_PartsCount INT = 0,
			@v_SeparatorIndex INT,
			@v_CurrentPart VARCHAR(255) = '',
			@v_Part1 VARCHAR(255) = '',
			@v_Part2 VARCHAR(255) = '',
			@v_Part3 VARCHAR(255) = '',
			@v_Part4 VARCHAR(255) = '',
			@v_TempObjectFlag BIT

	SELECT @v_Server = '', @v_Database = '', @v_Schema = '', @v_Object = '';
	SET @v_TmpStr = @v_Name;
	SET @v_NumberOfParts = (LEN(@v_TmpStr) - LEN(REPLACE(@v_TmpStr, @v_Separator, ''))) + 1
	SET @v_TmpStr = LTRIM(RTRIM(@v_Name));

	SET @v_CorrectedName = @v_TmpStr -- at first use the same name for corrected name

	IF @v_NumberOfParts = 1 
	BEGIN 
		SET @v_Part1 = LTRIM(RTRIM(@v_TmpStr))
	END 
	ELSE BEGIN 
		WHILE 
			(@v_PartsCount < @v_NumberOfParts)				--no more string
			AND (CHARINDEX(@v_Separator, @v_TmpStr)) != 0	--no more parts
		BEGIN
			SET @v_PartsCount = @v_PartsCount + 1
			
			SET @v_SeparatorIndex = CHARINDEX(@v_Separator, @v_TmpStr);
			SET @v_CurrentPart = SUBSTRING (@v_TmpStr , 1, @v_SeparatorIndex -1 )
			SET @v_TmpStr = RIGHT(@v_TmpStr, LEN(@v_TmpStr)-@v_SeparatorIndex);
			
			IF @v_PartsCount = 1 BEGIN SET @v_Part1 = LTRIM(RTRIM(@v_CurrentPart)); SET @v_Part2 = LTRIM(RTRIM(@v_TmpStr)); END
			IF @v_PartsCount = 2 BEGIN SET @v_Part2 = LTRIM(RTRIM(@v_CurrentPart)); SET @v_Part3 = LTRIM(RTRIM(@v_TmpStr)); END
			IF @v_PartsCount = 3 BEGIN SET @v_Part3 = LTRIM(RTRIM(@v_CurrentPart)); SET @v_Part4 = LTRIM(RTRIM(@v_TmpStr)); END
		END
	END
	
	--select @v_Part1, @v_Part2, @v_Part3, @v_Part4	
	IF @v_NumberOfParts = 4 SELECT @v_Server = @v_Part1, @v_Database = @v_Part2, @v_Schema = @v_Part3, @v_Object = @v_Part4;
	IF @v_NumberOfParts = 3 SELECT @v_Database = @v_Part1, @v_Schema = @v_Part2, @v_Object = @v_Part3;
	IF @v_NumberOfParts = 2 SELECT @v_Schema = @v_Part1, @v_Object = @v_Part2;
	IF @v_NumberOfParts = 1 SELECT @v_Object = @v_Part1;

	--cleanup brackets
	SET @v_Server = REPLACE(REPLACE(@v_Server, ']', ''), '[', ''); 
	SET @v_Database = REPLACE(REPLACE(@v_Database, ']', ''), '[', ''); 
	SET @v_Schema = REPLACE(REPLACE(@v_Schema, ']', ''), '[', ''); 
	SET @v_Object = REPLACE(REPLACE(@v_Object, ']', ''), '[', ''); 

	IF LTRIM(RTRIM(@v_Schema)) = '' SET @v_Schema = 'dbo'; --default schema is DBO

	--correct temp DB settings 
	SET @v_TempObjectFlag = CASE WHEN CHARINDEX('#',@v_Object) != 0 THEN 1 ELSE 0 END;
	IF @v_CorrectTempTablesLocation = 1 AND @v_TempObjectFlag = 1
	BEGIN 
		SET @v_Database = 'TEMPDB';
		SET @v_Schema = 'dbo';
	END 

	IF LTRIM(RTRIM(@v_Database)) = '' SET @v_Database = DB_NAME(); --default database is database in which we run

	SET @v_Server = CASE WHEN @v_Server IS NULL OR @v_Server = '' THEN '' ELSE '['+@v_Server+']' END; 
	SET @v_Database = CASE WHEN @v_Database IS NULL OR @v_Database = '' THEN '' ELSE '['+@v_Database+']' END;
	SET @v_Schema = CASE WHEN @v_Schema IS NULL OR @v_Schema = '' THEN '' ELSE '['+@v_Schema+']' END;
	SET @v_Object = CASE WHEN @v_Object IS NULL OR @v_Object = '' THEN '' ELSE '['+@v_Object+']' END;

		-- reconstruct the name 
	SET @v_CorrectedName = 
			CASE WHEN @v_Server != '' THEN @v_Server + '.' ELSE '' END 
			+ CASE 
				WHEN @v_Database != '' THEN @v_Database + '.' 
				WHEN @v_Server != '' THEN '.'
				ELSE '' 
			END 
			+ CASE WHEN @v_Schema != '' THEN @v_Schema + '.' ELSE '' END --we will always have schema
			+ @v_Object;
END

GO
