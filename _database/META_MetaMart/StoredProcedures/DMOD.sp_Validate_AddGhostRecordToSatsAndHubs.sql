SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [DMOD].[sp_Validate_AddGhostRecordToSatsAndHubs]
@Databasename varchar(100)
AS
--DECLARE @Databasename varchar(100)
DECLARE
	  @sql nvarchar(max)
	, @FieldList varchar(max)
	, @ValuesList varchar(max)
	, @TblCount int
	, @TblFieldCount int
	, @TblNo int
	, @TblName varchar(100)
	, @TblFieldNo int
	, @TblFieldType varchar(50)
	, @TblFieldName varchar(100)
	, @HKColumnName varchar(100)

DROP TABLE IF EXISTS #TblList

SELECT
	t.[object_id] AS TableID
	, t.[name] AS TableName
	, s.[name] aS SchemaName
	, ROW_NUMBER() OVER(ORDER BY t.[name] ASC) AS RowNo
INTO #TblList
FROM 
	sys.objects t
		INNER JOIN sys.schemas  s ON t.schema_id = s.schema_id 
WHERE
	t.[type] = 'U'
	--AND t.[name] = 'HUB_Supplier'
	AND (t.[name] like 'HUB_%' OR t.[name] like 'SAT_%')
	AND UPPER(t.[name]) not like '%TODELETE%'
	AND UPPER(t.[name]) not like '%TEST%'

	--SELECT 'SELECT TOP 1 * FROM raw.' + 'SAT_SalesOrder_D365_MVD' + ' WHERE UPPER(HK' + SUBSTRING('SAT_SalesOrder_D365_MVD',4,CHARINDEX('_', 'SAT_SalesOrder_D365_MVD', 5)-4) + ') = ''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''
	--SELECT TOP 1 * FROM raw.SAT_SalesOrder_D365_MVD WHERE UPPER(HK_SalesOrder) = '3FEDA0153EEE1380B496298450DC5A74324EB8C1'

SELECT
	@TblCount = COUNT(*)
FROM
	#TblList

SELECT @TblNo = 0

WHILE @TblNo < @TblCount 
BEGIN
	SELECT @TblNo = @TblNo + 1

	SELECT @TblName = (SELECT TableName FROM #TblList WHERE RowNo = @TblNo)

	-- SAT 
	--SELECT @sql = 'SELECT TOP 1 * FROM ' + (SELECT SchemaName FROM #TblList WHERE RowNo = @TblNo) + '.' + @TblName + ' WHERE UPPER(HK' + SUBSTRING(@TblName,4,CHARINDEX('_', @TblName, 5)-4) + ') = ''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''
	SELECT @HKColumnName = c.name
	FROM sys.columns c 
		INNER JOIN sys.tables t ON
			t.object_id = c.object_id
	WHERE t.name = @TblName
		AND c.name like 'HK_%'
	--HUB
		--IF @TblName like 'HUB_%'
		--BEGIN
		--	SELECT @sql = 'SELECT TOP 1 * FROM ' + (SELECT SchemaName FROM #TblList WHERE RowNo = @TblNo) + '.' + @TblName + ' WHERE UPPER(HK_' + SUBSTRING(@TblName, 5, LEN(@TblName)) + ') = ''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''
		--END
		--IF @TblName like 'SAT_%'
		--BEGIN

	SELECT @sql = 'SELECT TOP 1 * FROM ' + (SELECT SchemaName FROM #TblList WHERE RowNo = @TblNo) + '.' + @TblName + ' WHERE UPPER(' + @HKColumnName + ') = ''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''
		
		--END

	EXECUTE sp_executesql @sql

	IF @@ROWCOUNT = 0 
	BEGIN

		SELECT @FieldList = '', @ValuesList = ''
	
		DROP TABLE IF EXISTS #TblFieldList

		SELECT
			'['+CONVERT(varchar(MAX),col.[name])+']' AS FieldName
			, '['+CONVERT(varchar(MAX),st.[name])+']' AS DataType
			, CONVERT(varchar(MAX),col.[column_id]) AS RowNo
		INTO
			#TblFieldList
		FROM
			sys.columns col
				INNER JOIN sys.types st ON col.system_type_id = st.system_type_id AND col.user_type_id = st.user_type_id 
		WHERE
			[object_id] = (SELECT TableID FROM #TblList WHERE RowNo = @TblNo)
		SELECT @TblName
		SELECT * FROM #TblFieldList
	
		SELECT
			@TblFieldCount = COUNT(*)
		FROM
			#TblFieldList 

		SELECT @TblFieldNo = 0

		WHILE @TblFieldNo < @TblFieldCount 
		BEGIN

			SELECT @TblFieldNo = @TblFieldNo + 1

			SELECT @TblFieldName = (SELECT FieldName FROM #TblFieldList WHERE RowNo = @TblFieldNo)
		
			SELECT @FieldList = @FieldList + ', ' + @TblFieldName

			SELECT @TblFieldType = (SELECT DataType FROM #TblFieldList WHERE RowNo = @TblFieldNo)

			SELECT @ValuesList = @ValuesList + ', ' + CASE
				WHEN SUBSTRING(@TblFieldName, 1, 3) = 'HK_' THEN '''3FEDA0153EEE1380B496298450DC5A74324EB8C1'''
				WHEN @TblFieldName = 'RecSrcDataEntityID' THEN '0'
				WHEN @TblFieldType = 'numeric' THEN '-1'
				WHEN @TblFieldType = 'bigint' THEN '-1'
				WHEN @TblFieldType = 'decimal' THEN '-1'
				WHEN @TblFieldType = 'float' THEN '-1'
				WHEN @TblFieldType = 'money' THEN '-1'
				WHEN @TblFieldType = 'real' THEN '-1'
				WHEN @TblFieldType = 'int' THEN '-1'
				WHEN @TblFieldType = 'tinyint' THEN '0'
				WHEN @TblFieldType = 'smallint' THEN '-1'
				WHEN @TblFieldType = 'date' THEN '''1900-01-01'''
				WHEN @TblFieldType = 'datetime' THEN '''1900-01-01'''
				WHEN @TblFieldType = 'datetime2' THEN '''1900-01-01'''
				WHEN @TblFieldType = 'datetimeoffset' THEN '''1900-01-01'''
				WHEN @TblFieldType = 'smalldatetime' THEN '''1900-01-01'''
				WHEN @TblFieldType = 'varchar' THEN '''NA'''
				WHEN @TblFieldType = 'nvarchar' THEN '''NA'''
				WHEN @TblFieldType = 'varbinary' THEN 'CONVERT(varbinary, ''NA'')'
			END

			--SELECT @ValuesList 

		END

		SELECT @FieldList = SUBSTRING(@FieldList, 3, LEN(@fieldList))
		SELECT @ValuesList = SUBSTRING(@ValuesList, 3, LEN(@ValuesList))

		SELECT @sql = 'INSERT INTO ' + @Databasename + '.' + (SELECT SchemaName FROM #TblList WHERE RowNo = @TblNo) + '.' + @TblName + ' (' + @FieldList + ') '
		SELECT @sql = @sql + 'VALUES (' + @ValuesList + ')'

		--SELECT @FieldList
		--SELECT @ValuesList
		
		--SELECT @sql
		EXECUTE sp_executesql @sql
	END

END

GO
