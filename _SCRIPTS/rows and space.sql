USE [master]
GO
/****** Object:  StoredProcedure [dbo].[RowsAndSpace_Get]    Script Date: 2020/06/12 1:41:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- {{DOCSTRING BEGIN}}
-- {{Created}} DataManager_Local.dbo.RowsAndSpace_Get; Emile Fraser; 2020-01-30
-- {{Updates}}
-- Returns RowCount, Data or Index space, Used and Unused
-- depending on the measure the user sends it for retrieval
-- {{DOCSTRING END}}
ALTER   PROCEDURE [dbo].[RowsAndSpace_Get]
	@DatabaseName SYSNAME
,	@SchemaName SYSNAME
,	@DataEntityName SYSNAME
,	@Filter AS SYSNAME = NULL
,	@Measure AS VARCHAR(20) -- Rows
,	@MeauseValue BIGINT OUTPUT
AS
BEGIN

	DECLARE @sql_statement NVARCHAR(MAX)
	DECLARE @sql_message NVARCHAR(MAX)
	DECLARE @sql_parameters NVARCHAR(MAX)
	DECLARE @sql_isdebug BIT = 1

	DECLARE @tvp_rowsandspace TABLE (SchemaName SYSNAME, TableName SYSNAME, Space_Total BIGINT, Space_Used BIGINT, Space_Unused BIGINT)

SET @sql_statement = 
'
	INSERT INTO @tvp_rowsandspace
	SELECT 
		s.name AS SchemaName
	,	t.name AS TableName,
	,	p.rows AS Count_Rows,
    ,	SUM(a.total_pages) * 8 * 1024 AS Space_Total
    ,	SUM(a.used_pages)  * 8 * 1024 AS Space_Used
    ,	(SUM(a.total_pages) - SUM(a.used_pages))  * 8 * 1024 AS Space_Unused
	FROM 
		' + @DatabaseName + '.sys.tables t
	INNER JOIN      
		' + @DatabaseName + '.sys.indexes i
			ON t.object_id = i.object_id
	INNER JOIN 
		' + @DatabaseName + '.sys.partitions p
			ON  i.object_id = p.OBJECT_ID 
			AND i.index_id = p.index_id
	INNER JOIN 
		' + @DatabaseName + '.sys.allocation_units a 
			ON p.partition_id = a.container_id
	INNER JOIN
		' + @DatabaseName + '.sys.schemas s 
			ON t.schema_id = s.schema_id
	WHERE 
		   t.name = ''' + @DataEntityName + '''
	   AND s.name = '''  + @SchemaName + '''
	   AND t.name NOT LIKE ''dt%''
	   AND t.is_ms_shipped = 0
	   AND i.object_id > 255
	GROUP BY 
		s.name t.name, p.rows
'

SET @sql_parameters = '@DatabaseName SYSNAME, @SchemaName SYSNAME, @DataEntityName SYSNAME'
EXEC sp_executesql @stmt = @sql_statement, @param = @sql_parameters, @DatabaseName = @DatabaseName, @SchemaName = @SchemaName, @DataEntityName = @DataEntityName

SELECT * FROM @tvp_rowsandspace
--EXEC sp_spaceused N'{dbo}.{table_name}';  

--	SET @MeasureValue = 


END