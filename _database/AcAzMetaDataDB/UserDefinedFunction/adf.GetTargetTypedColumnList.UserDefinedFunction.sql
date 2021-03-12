SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetTargetTypedColumnList]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	SELECT  adf.[GetTargetTypedColumnList] (''lnd'', ''MATDOC_Material_Documents_PROD'')
*/

CREATE   FUNCTION [adf].[GetTargetTypedColumnList] (
	 @TargetSchema SYSNAME
,	 @TargetTable SYSNAME
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @MinSizeForPrecision INT = (SELECT MAX(LEN(KEY_ATTRIBUTE_DECIMAL)) FROM dc.exception)
	DECLARE @MaxColumnId INT = (SELECT MAX(col.column_id) FROM sys.columns AS col INNER JOIN sys.tables AS tab ON tab.object_id = col.object_id INNER JOIN sys.schemas AS sch ON sch.schema_id = tab.schema_id WHERE sch.name = @TargetSchema AND tab.name = @TargetTable)

	DECLARE @ColumnList NVARCHAR(MAX) = ''''
	SELECT @ColumnList +=
	 ''CONVERT('' + UPPER(typ.[name]) + CASE WHEN typ.[is_user_defined] = 0
														THEN  ISNULL(''('' + CASE WHEN typ.[name] IN (''binary'', ''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'')
																					THEN CASE col.[max_length] 
																				WHEN -1
																					THEN ''MAX''
								   ELSE
									   CASE
										   WHEN typ.[name] IN (''nchar'', ''nvarchar'')
											   THEN
												   CAST(col.[max_length] / 2 AS VARCHAR(4))
										   ELSE
											   CAST(col.[max_length] AS VARCHAR(4))
									   END
							   END
					   WHEN typ.[name] IN (''datetime2'', ''datetimeoffset'', ''time'')
						   THEN
							   CAST(col.[scale] AS VARCHAR(4))
					   WHEN typ.[name] IN (''decimal'', ''numeric'')
						   THEN
								CASE WHEN col.[precision] - col.[scale] - @MinSizeForPrecision < 0
									THEN CAST(ABS(col.[precision] - col.[scale] - @MinSizeForPrecision) + col.[precision] AS VARCHAR(4))
									ELSE CAST(col.[precision] AS VARCHAR(4))
								END + '', ''
							   + CAST(col.[scale] AS VARCHAR(4))
				   END
				  + '')'', '''')
		  ELSE
			  '':''
			  + (
				  SELECT
					  [c_t].[name]
					  + ISNULL(
					  ''(''
					  + CASE
						   WHEN [c_t].[name] IN (''binary'', ''char'', ''nchar'', ''varchar'', ''nvarchar'', ''varbinary'')
							   THEN
								   CASE [c].[max_length]
									   WHEN -1
										   THEN
											   ''MAX''
									   ELSE
										   CASE
											   WHEN typ.[name] IN (''nchar'', ''nvarchar'')
												   THEN
													   CAST([c].[max_length] / 2 AS VARCHAR(4))
											   ELSE
												   CAST([c].[max_length] AS VARCHAR(4))
										   END
								   END
						   WHEN [c_t].[name] IN (''datetime2'', ''datetimeoffset'', ''time'')
							   THEN
								   CAST([c].[scale] AS VARCHAR(4))
						   WHEN [c_t].[name] IN (''decimal'', ''numeric'')
							   THEN
								   CAST([c].[precision] AS VARCHAR(4))
								   + '', ''
								   + CAST([c].[scale] AS VARCHAR(4))
					   END
					  + '')'', '''')
				  FROM
					  [sys].[columns] AS [c]
					  INNER JOIN
						  [sys].[types] AS [c_t]
						  ON [c].[system_type_id] = [c_t].[user_type_id]
				  WHERE
					  [c].object_id = col.object_id
					  AND [c].[column_id] = col.[column_id]
					  AND [c].[user_type_id] = col.[user_type_id]
			  )
	  END + '', '' --+ IIF(col.column_id != @MaxColumnId, ''),'' + CHAR(13)  + CHAR(10),'''')
	 + CASE
		  WHEN typ.[name] = ''date''
			  THEN ''IIF('' + QUOTENAME(col.[name]) + '' = ''''00000000'''', ''''19000101'''', '' + QUOTENAME(col.[name])+ '')),'' + CHAR(13) + CHAR(10)
		  WHEN typ.[name] = ''time''
			  THEN ''CONVERT(NVARCHAR(8), [adf].[GetTimeValueFromTimeStringValue]('' + QUOTENAME(col.[name]) + ''))'' + IIF(col.column_id != @MaxColumnId,''),'' + CHAR(13)  + CHAR(10),'')'')
			  ELSE QUOTENAME(col.[name]) + IIF(col.column_id != @MaxColumnId,''),'' + CHAR(13)  + CHAR(10),'')'')
		 END
		-- + CHAR(13)  + CHAR(10)
	FROM
		[sys].[tables] AS tab
	INNER JOIN
		[sys].[schemas] AS sch
		ON sch.schema_id = tab.schema_id
	LEFT JOIN
		[sys].[columns] AS col
		ON tab.object_id = col.object_id
	LEFT JOIN
		[sys].[types] AS typ
		ON col.[user_type_id] = typ.[user_type_id]
	LEFT JOIN
		[sys].[computed_columns] AS [cc]
		ON tab.object_id = [cc].object_id
		AND col.[column_id] = [cc].[column_id]
	WHERE
		  tab.[name] = @TargetTable
	AND
		cc.column_id IS NULL
	ORDER BY
		sch.[name]
	  , tab.[name]
	  , col.[column_id]
	
	RETURN @ColumnList
	
END
' 
END
GO
