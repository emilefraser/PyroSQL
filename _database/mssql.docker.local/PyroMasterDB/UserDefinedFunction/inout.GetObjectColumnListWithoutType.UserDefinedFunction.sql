SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[GetObjectColumnListWithoutType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
/*
	Created By: Emile Fraser
	Date: 2021-04-20
	Description: Gets the full column list without DataTypes

	Test1: SELECT [inout].[GetObjectColumnListWithoutType]( ''AdventureWorks'', ''Person'', ''Address'')

*/
CREATE     FUNCTION [inout].[GetObjectColumnListWithoutType] (
    @DatabaseName				SYSNAME
,	@SchemaName					SYSNAME
,	@ObjectName					SYSNAME
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	DECLARE 
		@ReturnValue NVARCHAR(MAX) = ''''

	;WITH cte_maxcolumn AS (
		SELECT 
			ColumnCount
		FROM  
			[meta].[Metadata_Table]
		WHERE
			DatabaseName = @DatabaseName
		AND	
			SchemaName = @SchemaName
		AND	
			TableName = @ObjectName
	), cte_columnlist AS (
		SELECT 
			ColumnList = QUOTENAME(col.ColumnName) 						
							+ IIF(col.ColumnId != cte_max.ColumnCount, '','' + CHAR(13) + CHAR(10), '''')
		,	ColumnNumber	= col.ColumnId
		FROM 
			[meta].[Metadata_Column] AS col
		CROSS JOIN	
			cte_maxcolumn AS cte_max
		WHERE
			col.DatabaseName = @DatabaseName
		AND	
			col.SchemaName = @SchemaName
		AND	
			col.TableName = @ObjectName
	
	) 
	SELECT 
		@ReturnValue += cte_columnlist.ColumnList
	FROM 
		cte_columnlist
	ORDER BY 
		cte_columnlist.ColumnNumber

	RETURN @ReturnValue

END

' 
END
GO
