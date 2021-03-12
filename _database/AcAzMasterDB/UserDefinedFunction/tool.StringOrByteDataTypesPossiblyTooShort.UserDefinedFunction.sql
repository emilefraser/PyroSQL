SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[StringOrByteDataTypesPossiblyTooShort]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Written by: EMile Fraser
	Date: 2020-10-01
	Identifies and corrects numerics that are too short

	SELECT * FROM tool.StringOrByteDataTypesPossiblyTooShort(''ext'') 
	SELECT * FROM tool.NumericDataTypesPossiblyTooShort() where [schemaname] = ''raw''
	SELECT * FROM tool.NumericDataTypesPossiblyTooShort() where [schemaname] = ''stage'' AND tablename not like ''TMP%''
*/
CREATE   FUNCTION [tool].[StringOrByteDataTypesPossiblyTooShort](
	@TargetSchemaName SYSNAME
)
RETURNS TABLE
AS
RETURN 

SELECT	
	tar.*, src.[max_length] AS MaxLength_SRC, src.[fulltablename] AS FullTableName_SRC
FROM  (
	SELECT
		SCHEMA_NAME([t].schema_id)  AS [schemaname]
	  ,	[t].[name]  AS [tablename]
	  ,	SCHEMA_NAME([t].schema_id) + ''.'' + [t].[name] AS [fulltablename]
	  , [c].[column_id]
	  , [c].[name] AS [columnname]
	  , TYPE_NAME([user_type_id]) AS [datatype]
	  , [max_length]
	  , [c].[is_nullable]
	  , ''ALTER TABLE '' + QUOTENAME([s].[name]) + ''.'' + QUOTENAME([t].[name]) + '' ALTER COLUMN '' + QUOTENAME([c].[name]) 
	  --+
		--	'' '' + TYPE_NAME([user_type_id]) + ''('' + CONVERT(NVARCHAR(4), [precision] + ABS([precision] - [scale] - 4)) +
		--	'','' + CONVERT(NVARCHAR(2), [scale]) + '') '' + IIF([c].[is_nullable] = 1, '' NULL'', '' NOT NULL'') 
		AS StatementToCorrect
	FROM
		[sys].[columns] AS [c]
	JOIN
		[sys].[tables] AS [t]
		ON [t].object_id = [c].object_id
	JOIN
		[sys].[schemas] AS [s]
		ON [s].schema_id = [t].schema_id
	WHERE TYPE_NAME([user_type_id]) IN (
		''varchar''
	  , ''char''
	  , ''nvarchar''
	) 
	AND
		s.name = @TargetSchemaName

) AS tar

LEFT JOIN (

	SELECT
		SCHEMA_NAME([t].schema_id)  AS [schemaname]
	  ,	CASE @TargetSchemaName
					WHEN ''ext'' THEN REPLACE([t].[name], ''_PROD'', '''')
					ELSE [t].[name] 
		END AS [tablename]
	  ,	SCHEMA_NAME([t].schema_id) + ''.'' + CASE @TargetSchemaName
					WHEN ''ext'' THEN REPLACE([t].[name], ''_PROD'', '''')
					ELSE [t].[name] 
		END AS [fulltablename]
	  , [c].[column_id]
	  , [c].[name] AS [columnname]
	  , TYPE_NAME([user_type_id]) AS [datatype]
	  , [max_length]
	  , [c].[is_nullable]
	  , ''ALTER TABLE '' + QUOTENAME([s].[name]) + ''.'' + QUOTENAME([t].[name]) + '' ALTER COLUMN '' + QUOTENAME([c].[name]) 
	  --+
		--	'' '' + TYPE_NAME([user_type_id]) + ''('' + CONVERT(NVARCHAR(4), [precision] + ABS([precision] - [scale] - 4)) +
		--	'','' + CONVERT(NVARCHAR(2), [scale]) + '') '' + IIF([c].[is_nullable] = 1, '' NULL'', '' NOT NULL'') 
		AS StatementToCorrect
	FROM
		[sys].[columns] AS [c]
	JOIN
		[sys].[tables] AS [t]
		ON [t].object_id = [c].object_id
	JOIN
		[sys].[schemas] AS [s]
		ON [s].schema_id = [t].schema_id
	WHERE TYPE_NAME([user_type_id]) IN (
		''varchar''
	  , ''char''
	  , ''nvarchar''
	) 
	AND
		s.name = CASE @TargetSchemaName
					WHEN ''ext'' THEN ''lnd''
					WHEN ''stage''  THEN ''ext''
					WHEN ''raw'' THEN ''stage''
					ELSE ''''
				END
	AND
		1 = CASE 
				WHEN @TargetSchemaName = ''ext'' AND t.name LIKE ''%_PROD'' THEN 1
				WHEN @TargetSchemaName = ''ext'' AND t.name NOT LIKE ''%_PROD'' THEN 0
				ELSE 1
			END

) AS src

ON 
	src.[tablename] = tar.[tablename]
AND
	src.[columnname] = tar.[columnname]
WHERE
	tar.fulltablename = ''ext.BKPF_Accounting_Document_Header''
--WHERE
--	src.max_length > tar.max_length
' 
END
GO
