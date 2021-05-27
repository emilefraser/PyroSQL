SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[tool].[NumericDataTypesPossiblyTooShort]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	Written by: EMile Fraser
	Date: 2020-10-01
	Identifies and corrects numerics that are too short

	SELECT * FROM tool.NumericDataTypesPossiblyTooShort() where [schemaname] = ''raw''
*/
CREATE   FUNCTION [tool].[NumericDataTypesPossiblyTooShort]()

RETURNS TABLE
AS
RETURN 

SELECT
	SCHEMA_NAME([t].schema_id)  AS [schemaname]
  ,	[t].[name]  AS [tablename]
  ,	SCHEMA_NAME([t].schema_id) + ''.'' + [t].[name] AS [fulltablename]
  , [c].[column_id]
  , [c].[name] AS [columnname]
  , TYPE_NAME([user_type_id]) AS [datatype]
  , [max_length]
  , [precision]
  , [scale]
  , [precision] - [scale] - 4 AS [undersized]
  , ABS([precision] - [scale] - 4) AS [correction]
  , [c].[is_nullable]
  , ''ALTER TABLE '' + QUOTENAME([s].[name]) + ''.'' + QUOTENAME([t].[name]) + '' ALTER COLUMN '' + QUOTENAME([c].[name]) +
		'' '' + TYPE_NAME([user_type_id]) + ''('' + CONVERT(NVARCHAR(4), [precision] + ABS([precision] - [scale] - 4)) +
		'','' + CONVERT(NVARCHAR(2), [scale]) + '') '' + IIF([c].[is_nullable] = 1, '' NULL'', '' NOT NULL'') AS StatementToCorrect
FROM
	[sys].[columns] AS [c]
JOIN
	[sys].[tables] AS [t]
	ON [t].object_id = [c].object_id
JOIN
	[sys].[schemas] AS [s]
	ON [s].schema_id = [t].schema_id
WHERE TYPE_NAME([user_type_id]) IN (
	''decimal''
  , ''numeric''
) 
--AND [t].[name] = ''MARA_material_data'' 
AND [precision] - [scale] - 4 < 0
' 
END
GO
