SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[GetRowCountFromPartition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT * FROM [measure].[GetRowCountFromPartition] (DEFAULT, DEFAULT)
*/
CREATE   FUNCTION [measure].[GetRowCountFromPartition] (
	@SchemaName		SYSNAME		= NULL
,	@ObjectName		SYSNAME		= NULL
)
RETURNS TABLE
AS
RETURN
	SELECT
		orcfp.[DatabaseName]
	,	orcfp.[SchemaName]
	,	orcfp.[ObjectName]
	,	orcfp.[RowCount]
	FROM
		measure.ObjectRowCountFromPartition AS orcfp
	WHERE 
		orcfp.[SchemaName] = IIF(@SchemaName IS NULL, orcfp.[SchemaName], @SchemaName)
	AND
		orcfp.[ObjectName] = IIF(@ObjectName IS NULL, orcfp.[ObjectName], @ObjectName)

' 
END
GO
