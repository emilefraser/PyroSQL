SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[construct].[GetObjectColumnListWithoutType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2021-04-20
	Description: Gets the full column list without DataTypes

	Test1: SELECT * FROM [construct].[GetObjectColumnListWithoutType]( ''BI_DEV_DataVault'', ''raw'', ''HUB_Project'')

*/
CREATE   FUNCTION [construct].[GetObjectColumnListWithoutType] (
    @DatabaseName				SYSNAME
,	@SchemaName					SYSNAME
,	@ObjectName					SYSNAME
)
RETURNS TABLE
AS
RETURN
	WITH cte_maxcolumn AS (
		SELECT 
			DatabaseName
		,	SchemaName
		,	TableName
		,	ColumnCount
		FROM  
			[meta].[Metadata_Table]

	), cte_columnlist AS (
		SELECT 
			col.DatabaseName
		,	col.SchemaName
		,	col.TableName
		,	ColumnList = QUOTENAME(col.ColumnName) + CHAR(13) + CHAR(10) 						
							+ IIF(col.ColumnId = cte_max.ColumnCount, '''', '','')
							+ CHAR(13) + CHAR(10)
		FROM 
			[meta].[Metadata_Column] AS col
		INNER JOIN	
			cte_maxcolumn AS cte_max
			ON  cte_max.DatabaseName = col.DatabaseName
			AND cte_max.SchemaName	 = col.SchemaName
			AND cte_max.TableName	 = col.TableName
		WHERE
			col.DatabaseName = @DatabaseName
		AND	
			col.SchemaName = @SchemaName
		AND	
			col.TableName = @ObjectName
	) 
	SELECT 
		columnlist = STRING_AGG(ColumnList, '','')
	FROM 
		cte_columnlist


' 
END
GO
