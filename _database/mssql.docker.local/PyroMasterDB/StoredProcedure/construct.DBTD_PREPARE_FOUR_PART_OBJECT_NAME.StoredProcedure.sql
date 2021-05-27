SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[DBTD_PREPARE_FOUR_PART_OBJECT_NAME]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [construct].[DBTD_PREPARE_FOUR_PART_OBJECT_NAME] AS' 
END
GO

--************************************************************************************************
--Function prepares four part object name 'server.database.schema.object' base on the provided values
--INTERNAL: Do not use this function in your unit tests, procedure can be removed,
--          signature or procedure name can be changed at any release
ALTER PROCEDURE [construct].[DBTD_PREPARE_FOUR_PART_OBJECT_NAME]
(
	@v_Server	NVARCHAR(128),
	@v_Database NVARCHAR(128),
	@v_Schema	NVARCHAR(128),
	@v_Object	NVARCHAR(128),
	@v_FullName		SYSNAME OUTPUT,					-- Fully qualified SQL name
	@v_CorrectedName SYSNAME OUTPUT,	
	@v_CorrectTempTablesLocation BIT = 1
)
  
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @v_TempObjectFlag BIT 

	--Cleanup brackets
	SET @v_Server = LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(@v_Server,''), ']', ''), '[', ''))); 
	SET @v_Database = LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(@v_Database,''), ']', ''), '[', ''))); 
	SET @v_Schema = LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(@v_Schema,''), ']', ''), '[', ''))); 
	SET @v_Object = LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(@v_Object,''), ']', ''), '[', ''))); 

	IF @v_Schema = '' SET @v_Schema = 'dbo'; --default schema is DBO

	--Correct temp DB settings 
	SET @v_TempObjectFlag = CASE WHEN charindex('#',@v_Object) != 0 THEN 1 ELSE 0 END;
	IF @v_CorrectTempTablesLocation = 1	AND @v_TempObjectFlag = 1
	BEGIN 
		SET @v_Database = 'TEMPDB';
		SET @v_Schema = 'dbo';
	END 

	SET @v_Server	= CASE WHEN @v_Server IS NULL OR @v_Server = '' THEN '' ELSE '['+@v_Server+']' END; 
	SET @v_Database = CASE WHEN @v_Database IS NULL OR @v_Database = '' THEN '' ELSE '['+@v_Database+']' END;
	SET @v_Schema	= CASE WHEN @v_Schema IS NULL OR @v_Schema = '' THEN '' ELSE '['+@v_Schema+']' END;
	SET @v_Object	= CASE WHEN @v_Object IS NULL OR @v_Object = '' THEN '' ELSE '['+@v_Object+']' END;

	--Reconstruct the name 
	SET @v_CorrectedName = 
			CASE WHEN @v_Server != '' THEN @v_Server + '.' ELSE '' END 
			+ CASE 
				WHEN @v_Database != '' THEN @v_Database + '.' 
				WHEN @v_Server != '' THEN '.'
				ELSE '' 
			END 
			+ CASE WHEN @v_Schema != '' THEN @v_Schema + '.' ELSE '' END --we will always have schema
			+ @v_Object;
	SET @v_FullName = REPLACE(REPLACE(@v_CorrectedName, ']', ''), '[', '');
END

GO
