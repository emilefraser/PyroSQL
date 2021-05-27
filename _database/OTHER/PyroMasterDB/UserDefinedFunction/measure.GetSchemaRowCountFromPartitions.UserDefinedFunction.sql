SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[measure].[GetSchemaRowCountFromPartitions]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE     FUNCTION [measure].[GetSchemaRowCountFromPartitions] (@SchemaName SYSNAME, @StageOfLoad NVARCHAR(128))
RETURNS TABLE
AS
RETURN
	SELECT
			[StageOfLoad]	= @StageOfLoad
		  , [EntityName]	= tbl.[name]
		  , [DatabaseName]	= DB_NAME()
		  , [SchemaName]	= sch.[name]
		  , [TableName]		= tbl.[name]
		  , [RowCount]		= SUM(par.[rows]) 
		FROM
			[sys].[tables] AS tbl
		INNER JOIN
			[sys].[schemas] AS sch
			ON sch.schema_id = tbl.schema_id
		INNER JOIN
			[sys].[partitions] AS par
			ON tbl.object_id = par.object_id
		INNER JOIN
			[sys].[indexes] AS idx
			ON par.object_id = idx.object_id 
			AND par.[index_id] = idx.[index_id]
		WHERE 
			idx.[index_id] < 2 
		AND 
			sch.[name] = @SchemaName
		GROUP BY
			tbl.object_id
		  , tbl.[name]
		  , sch.[name]
' 
END
GO
