-- GET ROW COUNTS

-- Performs a full table scan. Slow on large tables.
SELECT COUNT(*) FROM Transactions


--Fast way to retrieve row count. Depends on statistics and is inaccurate.
--Run DBCC UPDATEUSAGE(Database) WITH COUNT_ROWS, which can take significant time for large tables.

SELECT CONVERT(bigint, rows)
FROM sysindexes
WHERE id = OBJECT_ID('Transactions')
AND indid < 2


--The way the SQL management studio counts rows (look at table properties, storage, row count). Very fast, but still an approximate number of rows.
SELECT CAST(p.rows AS float)
FROM sys.tables AS tbl
INNER JOIN sys.indexes AS idx ON idx.object_id = tbl.object_id and idx.index_id < 2
INNER JOIN sys.partitions AS p ON p.object_id=CAST(tbl.object_id AS int)
AND p.index_id=idx.index_id
WHERE ((tbl.name=N'Transactions'
AND SCHEMA_NAME(tbl.schema_id)='dbo'))



4-- Counting rows using sys.partitions catalog view

SELECT SUM (row_count)
FROM sys.dm_db_partition_stats
WHERE object_id=OBJECT_ID('Transactions')   
AND (index_id=0 or index_id=1);






 
-- Ensure a USE [databasename] statement has been executed first.
SELECT SCHEMA_NAME(t.[schema_id]) AS [table_schema]
      ,OBJECT_NAME(p.[object_id]) AS [table_name]
      ,SUM(p.[rows]) AS [row_count]
FROM [sys].[partitions] p
INNER JOIN [sys].[tables] t ON p.[object_id] = t.[object_id]
WHERE p.[index_id] < 2
GROUP BY p.[object_id]
    ,t.[schema_id]
ORDER BY 1, 2 ASC
OPTION (RECOMPILE);


--Counting table rows using sys.dm_db_partition_stats dynamic management view
-- Ensure a USE [databasename] statement has been executed first.
SELECT SCHEMA_NAME(t.[schema_id]) AS [table_schema]
      ,t.[name] AS [table_name]
      ,SUM(ps.[row_count]) AS [row_count]
FROM [sys].[tables] t
INNER JOIN [sys].[dm_db_partition_stats] ps
     ON ps.[object_id] = t.[object_id]
WHERE [index_id] < 2
GROUP BY t.[name]
    ,t.[schema_id]
ORDER BY 1, 2 ASC
OPTION (RECOMPILE);

-- Space Used
EXEC [sp_spaceused] 'Person.Address'

-- Dynamic procedure for counts
-- Ensure a USE [databasename] statement has been executed first.
DECLARE @Database                   [nvarchar] (256)
       ,@TSQLCommand01              [nvarchar] (MAX)
 
SET @Database = DB_NAME()
 
IF OBJECT_ID(N'TempDb.dbo.#Table_Size_Info') IS NOT NULL
    DROP TABLE #Table_Size_Info
 
CREATE TABLE #Table_Size_Info (
     [ID] [int] IDENTITY(1, 1) PRIMARY KEY
    ,[ObjectName] [sysname]
    ,[NumRows] [bigint]
    ,[Reserved] [varchar](30)
    ,[Data] [varchar](30)
    ,[IndexSize] [varchar](30)
    ,[Unused] [varchar](30)
    ,[ObjectType] [char](1)
    )
 
SET @TSQLCommand01 = N''
SET @TSQLCommand01 = N'USE' + SPACE(1) + QUOTENAME(@Database) + N';' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'DECLARE @SQLStatementID02 [smallint] ,' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'@CurrentObjectSchema         [sysname] ,' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'@CurrentObjectName           [sysname] ,' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'@CurrentObjectFullName [sysname] ,' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'@CurrentObjectType           [char](1)' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'DECLARE @AllObjects TABLE ( [ID] [int] IDENTITY(1, 1) PRIMARY KEY , [ObjectSchema] [sysname] , [ObjectName] [sysname] , [ObjectType] [char](1) , [Completed] [bit] );' + SPACE(1) + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'INSERT INTO @AllObjects ([ObjectSchema], [ObjectName], [ObjectType], [Completed])' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'SELECT  [TABLE_SCHEMA] , [TABLE_NAME] , N''T'' , 0' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'FROM    [INFORMATION_SCHEMA].[TABLES]' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'WHERE   [TABLE_TYPE] = N''BASE TABLE''' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'AND CHARINDEX(N'''''''' , [TABLE_NAME]) = 0' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'ORDER BY [TABLE_SCHEMA], [TABLE_NAME]' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'SELECT @SQLStatementID02 = MIN([ID]) FROM @AllObjects WHERE [Completed] = 0' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'WHILE @SQLStatementID02 IS NOT NULL' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'BEGIN' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'SELECT @CurrentObjectSchema = [ObjectSchema] , @CurrentObjectName = [ObjectName] , @CurrentObjectType = [ObjectType]' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'FROM @AllObjects WHERE [ID] = @SQLStatementID02' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'SET @CurrentObjectFullName = QUOTENAME(@CurrentObjectSchema) + ''.'' + QUOTENAME(@CurrentObjectName)' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'INSERT INTO #Table_Size_Info ([ObjectName] , [NumRows] , [Reserved] , [Data] , [IndexSize] , [Unused] )' + CHAR(13) + N'EXEC [sp_spaceused] @CurrentObjectFullName' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'UPDATE #Table_Size_Info SET [ObjectName] = @CurrentObjectFullName , [ObjectType] = @CurrentObjectType WHERE [ID] = SCOPE_IDENTITY();' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'UPDATE @AllObjects' + CHAR(13) + N'SET [Completed] = 1' + CHAR(13) + N'WHERE [ID] = @SQLStatementID02' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + CHAR(9) + N'SELECT @SQLStatementID02 = MIN([ID]) FROM @AllObjects WHERE [Completed] = 0' + CHAR(13)
SET @TSQLCommand01 = @TSQLCommand01 + N'END' + CHAR(13)
 
EXEC [sp_executesql] @TSQLCommand01
 
SELECT *
FROM #Table_Size_Info
GO

-- GET ALL TABLE INFO
SELECT SCHEMA_NAME([schema_id]) AS [schema_name]
      ,t.[name] AS [table_name]
      ,i.[name] AS [index_name]
      ,i.[type_desc] AS [index_type]
      ,ps.[name] AS [partition_scheme]
      ,pf.[name] AS [partition_function]
      ,p.[partition_number]
      ,r.[value] AS [current_partition_range_boundary_value]
      ,p.[rows] AS [partition_rows]
      ,p.[data_compression_desc]
FROM sys.tables t
INNER JOIN sys.partitions p ON p.[object_id] = t.[object_id]
INNER JOIN sys.indexes i ON p.[object_id] = i.[object_id]
                           AND p.[index_id] = i.[index_id]
INNER JOIN sys.data_spaces ds ON i.[data_space_id] = ds.[data_space_id]
INNER JOIN sys.partition_schemes ps ON ds.[data_space_id] = ps.[data_space_id]
INNER JOIN sys.partition_functions pf ON ps.[function_id] = pf.[function_id]
LEFT JOIN sys.partition_range_values AS r ON pf.[function_id] = r.[function_id]
    AND r.[boundary_id] = p.[partition_number]
GROUP BY SCHEMA_NAME([schema_id])
        ,t.[name]
        ,i.[name]
        ,i.[type_desc]
        ,ps.[name]
        ,pf.[name]
        ,p.[partition_number]
        ,r.[value]
        ,p.[rows]
        ,p.[data_compression_desc]
ORDER BY SCHEMA_NAME([schema_id])
        ,t.[name]
        ,i.[name]
        ,p.[partition_number];