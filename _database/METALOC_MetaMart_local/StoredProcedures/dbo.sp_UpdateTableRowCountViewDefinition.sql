SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_UpdateTableRowCountViewDefinition] AS


--Variable Declaration
DECLARE
	  @ItemCount int
	, @ItemNo int
	, @DBName varchar(100)
	, @sql nvarchar(max)

-- Set / Clear Variables
SET @sql = ''


-- Create Temp Table for databases
DROP TABLE IF EXISTS #Databases

CREATE TABLE #Databases 
	(
	  RowNo int NOT NULL
	, DatabaseName varchar(100) NOT NULL
	)


-- Add all non-system (>4) databases to temp table
INSERT INTO
	#Databases
SELECT
	ROW_NUMBER() OVER(ORDER BY [name] ASC) AS RowNo
	, [name] AS DatabaseName
FROM
	sys.databases
WHERE
	database_id > 4

-- Initiate @sql script for View Creation
SET @sql = 'CREATE VIEW [dbo].[vw_rpt_TableRowcounts] AS' + CHAR(10) + CHAR(13)

SET @ItemNo = 1  --First Database


SELECT @DBName = DatabaseName FROM #Databases WHERE RowNo = @ItemNo

IF @DBName not like '%DataManager%' AND @DBName not like '%Sandbox%' AND @DBName not like '%SSIS%'
BEGIN
	SET
		@sql = @sql + 'SELECT ''' + @DBName + ''' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount '
					+ 'FROM (SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id FROM [' + @DBName + '].sys.tables t INNER JOIN [' + @DBName + '].sys.schemas s ON t.schema_id = s.schema_id WHERE t.[type] = ''U'') AS TBL '
					+ 'INNER JOIN [' + @DBName + '].sys.partitions AS PART	ON TBL.object_id = PART.object_id  '
					+ 'INNER JOIN [' + @DBName + '].sys.indexes AS IDX		ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id '
					+ 'WHERE IDX.index_id < 2 '
					+ 'GROUP BY TBL.SchemaName, TBL.[name] '

	SET @sql = @sql + CHAR(10) + CHAR(13)
END

SET @ItemNo = @ItemNo + 1

SELECT
	@ItemCount = COUNT(1)
FROM
	#Databases

WHILE @ItemNo < @ItemCount
BEGIN

	SET @ItemNo = @ItemNo + 1

	SELECT @DBName = DatabaseName FROM #Databases WHERE RowNo = @ItemNo

	IF @DBName not like '%DataManager%' AND @DBName not like '%Sandbox%' AND @DBName not like '%SSIS%'
	BEGIN
	
		IF LEN(@sql) > 54
			SET @sql = @sql + 'UNION ALL '  + CHAR(10) + CHAR(13)

		SET
			@sql = @sql + 'SELECT ''' + @DBName + ''' AS DatabaseName, TBL.SchemaName, TBL.[name], SUM(PART.rows) AS TBLRowCount '
						+ 'FROM (SELECT t.[object_id], t.[name], s.[name] as SchemaName, t.schema_id FROM [' + @DBName + '].sys.tables t INNER JOIN [' + @DBName + '].sys.schemas s ON t.schema_id = s.schema_id WHERE t.[type] = ''U'') AS TBL '
						+ 'INNER JOIN [' + @DBName + '].sys.partitions AS PART	ON TBL.object_id = PART.object_id  '
						+ 'INNER JOIN [' + @DBName + '].sys.indexes AS IDX		ON PART.object_id = IDX.object_id AND PART.index_id = IDX.index_id '
						+ 'WHERE IDX.index_id < 2 '
						+ 'GROUP BY TBL.SchemaName, TBL.[name] '

		SET @sql = @sql + CHAR(10) + CHAR(13)
	END

END

EXECUTE sp_executesql N'DROP VIEW IF EXISTS [dbo].[vw_rpt_TableRowcounts]'

EXECUTE sp_executesql @sql



GO
