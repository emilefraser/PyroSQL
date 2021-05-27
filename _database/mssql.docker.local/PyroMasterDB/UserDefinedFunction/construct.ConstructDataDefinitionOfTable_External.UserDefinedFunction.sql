SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[ConstructDataDefinitionOfTable_External]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	
*/

CREATE    FUNCTION [construct].[ConstructDataDefinitionOfTable_External] (
	@SchemaName			 SYSNAME
  , @TableName           SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE
		@statement			NVARCHAR(MAX) = ''''
	  , @columnlist			NVARCHAR(MAX) = ''''
	  ,	@stage_ext			NVARCHAR(MAX) = ''_Staged''

	SELECT
		@columnlist += tab.[table_name]
	--				 ''CONVERT(''
	--				 + [t].[name]
	--				 + CASE
	--					   WHEN [t].[is_user_defined] = 0
	--						   THEN ISNULL(
	--									   ''(''
	--									   + CASE
	--											 WHEN [t].[name] IN(''binary'', ''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'')
	--												 THEN CASE [col].[max_length]
	--														  WHEN -1
	--															  THEN ''MAX''
	--															  ELSE CASE
	--																	   WHEN [t].[name] IN(''nchar'', ''nvarchar'')
	--																		   THEN CAST([col].[max_length] / 2 AS VARCHAR(4))
	--																		   ELSE CAST([col].[max_length] AS VARCHAR(4))
	--																   END
	--													  END
	--											 WHEN [t].[name] IN(''datetime2'', ''datetimeoffset'', ''time'')
	--												 THEN CAST([col].[scale] AS VARCHAR(4))
	--											 WHEN [t].[name] IN(''decimal'', ''numeric'')
	--												 THEN
	--													  CAST([col].[precision] AS VARCHAR(4))
	--													  + '', ''
	--													  + CAST([col].[scale] AS VARCHAR(4))
	--										 END
	--									   + '')'', '''')
	--						   ELSE
	--								'':''
	--								+ (
	--								SELECT
	--									[c_t].[name]
	--									+ ISNULL(
	--											 ''(''
	--											 + CASE
	--												   WHEN [c_t].[name] IN(''binary'', ''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'')
	--													   THEN CASE [c].[max_length]
	--																WHEN -1
	--																	THEN ''MAX''
	--																	ELSE CASE
	--																			 WHEN [t].[name] IN(''nchar'', ''nvarchar'')
	--																				 THEN CAST([c].[max_length] / 2 AS VARCHAR(4))
	--																				 ELSE CAST([c].[max_length] AS VARCHAR(4))
	--																		 END
	--															END
	--												   WHEN [c_t].[name] IN(''datetime2'', ''datetimeoffset'', ''time'')
	--													   THEN CAST([c].[scale] AS VARCHAR(4))
	--												   WHEN [c_t].[name] IN(''decimal'', ''numeric'')
	--													   THEN
	--															CAST([c].[precision] AS VARCHAR(4))
	--															+ '', ''
	--															+ CAST([c].[scale] AS VARCHAR(4))
	--											   END
	--											 + '')'', '''')
	--								FROM
	--									[sys].[columns] AS [c]
	--								INNER JOIN
	--									[sys].[types] AS [c_t]
	--									ON [c].[system_type_id] = [c_t].[user_type_id]
	--								WHERE [c].object_id = [col].object_id AND [c].[column_id] = [col].[column_id] AND [c].[user_type_id] = [col].[user_type_id]
	--)
	--				   END
	--						   + '', ''
	--						   + CASE
	--								 WHEN [t].[name] = ''date''
	--									THEN
	--										  ''IIF('' + QUOTENAME([col].[name]) + '' = ''''00000000'''', ''''19000101'''', ''
	--										  + QUOTENAME([col].[name])
	--										  + '')),'' 
	--								 WHEN [t].[name] = ''time''	
	--									THEN
	--										  ''[adf].[GetTimeStringFromTimeStringValue]('' + QUOTENAME([col].[name]) + '')'' + ''),''
	--									 ELSE
	--										  QUOTENAME([col].[name])  + ''),'' --+ CHAR(13)  + CHAR(10)
	--							 END

	--	+ CHAR(13) + CHAR(10)
	FROM
		demo.[dbo].[pg_columns] AS [col]
	INNER JOIN 
		demo.[dbo].[pg_tables] AS [tab]
		ON [tab].[table_name]  = [col].[table_name]
	INNER JOIN
		demo.[dbo].[pg_schemas] AS [sch]
		ON [sch].[schema_name] = [tab].[table_schema]
	WHERE 
		[sch].[schema_name] = ''MOTO_SALES''
	AND
		[tab].[table_name]  = ''invoice_lines''

	  set @columnlist = SUBSTRING(@columnlist, 1, len(@columnlist) - 1)

	SET @statement   = ''TRUNCATE TABLE '' + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName) + '';'' + CHAR(13) + CHAR(10)
	SET @statement	 = ''INSERT INTO ''    + QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@TableName) + CHAR(13) + CHAR(10)
	SET @statement	+= ''SELECT '' + CHAR(13) + CHAR(10)
	SET @statement	+= SUBSTRING(@columnlist, 1, LEN(@columnlist) - 2) + CHAR(13) + CHAR(10)
	SET @statement	+= ''FROM '' + CHAR(13) + CHAR(10) + CHAR(9)
					+ QUOTENAME(@SchemaName) + ''.'' + QUOTENAME(@SchemaName + @stage_ext)

	--RAISERROR(@statement, 0, 1)
	
	--SELECT
	--	LEN(@statement)

	RETURN
		@statement

	
	--EXEC sp_executesql @stmt = @statement

END

' 
END
GO
