SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Emile Fraser
-- Create Date: 16 Sep 2019
-- =============================================



-- SELECT [DataManager].[DC].[udf_get_TableSpaceAndRows]('[DataVault]', PARSENAME('[raw]',1), PARSENAME('[SAT_FeedPrice_XLS_MVD]',1))
CREATE FUNCTION [DC].[udf_get_TableSpaceAndRows]
(
		@DatabaseName SYSNAME
	,	@SchemaName SYSNAME
    ,	@DataEntityName SYSNAME
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	-- :>DEBUG>:
	--DECLARE @DatabaseName  AS SYSNAME = '[DEV_DataVault]'
	--DECLARE @SchemaName AS SYSNAME = '[raw]'
	--DECLARE @DataEntityName AS SYSNAME = '[SAT_EntityType_CP_MVD]'
	-- :>DEBUG>:

	DECLARE @SQL varchar(max) 

	-- Remove brackets if still exists
	SET @SchemaName = PARSENAME(@SchemaName, 1)
	SET @DataEntityName = PARSENAME(@DataEntityName, 1)

	SET @SQL = 
	'SELECT 
		t.name AS TableName,
		p.rows AS RowCounts,
		SUM(a.used_pages) * 8 AS UsedSpaceKB
	FROM '
		+ @DatabaseName + '.sys.tables t
	INNER JOIN '      
		+ @DatabaseName + '.sys.indexes i 
			ON t.OBJECT_ID = i.object_id
	INNER JOIN '
		+ @DatabaseName + '.sys.partitions p 
			ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN ' 
		+ @DatabaseName + '.sys.allocation_units a 
			ON p.partition_id = a.container_id
	LEFT OUTER JOIN ' 
		+ @DatabaseName + '.sys.schemas s 
			ON t.schema_id = s.schema_id
	WHERE 
		t.name = ''' + @DataEntityName + '''
	AND 
		s.name = ''' + @SchemaName + '''
	AND
		i.has_filter = 0
	GROUP BY 
		t.name, s.name, p.rows
	ORDER BY 
		t.name'

	--SELECT @SQL

	RETURN @SQL
END



GO
