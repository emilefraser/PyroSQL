SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[adf].[GetTargetColumnList]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	SELECT  adf.[GetTargetColumnList] (''lnd'', ''ACDOCA_Universal_Journal_Entry_Line_Items_PROD'')
*/

CREATE   FUNCTION [adf].[GetTargetColumnList] (
	 @TargetSchema SYSNAME
,	 @TargetTable SYSNAME
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @MaxColumnId INT = (SELECT MAX(col.column_id) FROM sys.columns AS col INNER JOIN sys.tables AS tab ON tab.object_id = col.object_id INNER JOIN sys.schemas AS sch ON sch.schema_id = tab.schema_id WHERE sch.name = @TargetSchema AND tab.name = @TargetTable)

	DECLARE @ColumnList NVARCHAR(MAX) = ''''
	SELECT @ColumnList += QUOTENAME(col.[name]) + IIF(col.column_id != @MaxColumnId,'','' + CHAR(13)  + CHAR(10),'''')
	FROM
		[sys].[tables] AS tab
	INNER JOIN
		[sys].[schemas] AS sch
		ON sch.schema_id = tab.schema_id
	LEFT JOIN
		[sys].[columns] AS col
		ON tab.object_id = col.object_id
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
