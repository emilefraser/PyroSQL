SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[GetObjectRowCountFromPartition]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
	SELECT * FROM [measure].[GetObjectRowCountFromPartition] (DEFAULT, ''TableName'')
*/
CREATE    FUNCTION [measure].[GetObjectRowCountFromPartition] (
	@SchemaName		SYSNAME		= ''dbo''
,	@ObjectName		SYSNAME
)
RETURNS INT
AS
BEGIN
	RETURN ((
		SELECT
			orcfp.[RowCount]
		FROM
			measure.ObjectRowCountFromPartition AS orcfp
		WHERE 
			orcfp.[SchemaName] = @SchemaName
		AND
			orcfp.[ObjectName] = @ObjectName
	))
END' 
END
GO
