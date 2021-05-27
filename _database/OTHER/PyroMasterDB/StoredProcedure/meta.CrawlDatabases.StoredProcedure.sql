SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[CrawlDatabases]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[CrawlDatabases] AS' 
END
GO
ALTER PROCEDURE [meta].[CrawlDatabases]
AS
BEGIN


CREATE TABLE #tmpTables (
    TableName NVARCHAR(300) NULL,
    TableId       INT
)


CREATE TABLE #tmpColumns (
    ColumnName NVARCHAR(300) NULL
)


CREATE TABLE #tmpSearchStrings (
    id int identity(1,1),
    SearchString NVARCHAR(500) NULL
)


DECLARE @Splited TABLE(id INT IDENTITY(1,1), item VARCHAR(MAX))

DECLARE
    @db_name        SYSNAME,
    @db_id          INT,   
    @cmd            NVARCHAR(300),
    @search_string  VARCHAR(300),
    @column_filter  VARCHAR(300),
    @table_name     SYSNAME,
    @table_id       INT,
    @column_name    SYSNAME,
    @sql_string     VARCHAR(2000),
    @sql_like_expr  VARCHAR(max)

-- init search string with search terms (comma separated for multiple)
SET @search_string = 'bill@microsoft.com,bgates@microsoft.com'
SET @search_string = REPLACE(@search_string,',',''' UNION ALL SELECT ''')
SET @search_string = ' SELECT  '''+ @search_string+'''  '

INSERT INTO #tmpSearchStrings
EXEC(@search_string)

-- crawl only tables with 'mail' has being part of their name
SET @column_filter = '%mail%'

-- init the main cursor that with cycle across all databases
-- note 'database_id > 4' is used to exclude system databases
DECLARE db_cur CURSOR FOR select name, database_id FROM SYS.databases WHERE database_id > 4 AND [name] NOT LIKE '%some_other_database_to_exclude%' ORDER BY name ASC
OPEN db_cur

FETCH NEXT FROM db_cur INTO @db_name, @db_id

WHILE (@@FETCH_STATUS = 0)
BEGIN   

    -- build query for finding tables for the current database
    SET @sql_string = 'SELECT name AS TableName, object_id AS TableId FROM [' + CONVERT(NVARCHAR, @db_name) + '].sys.tables'

    INSERT INTO #tmpTables
        EXECUTE(@sql_string)

    -- init the tables cursor to cycle through current database tables
    DECLARE tables_cur CURSOR FOR SELECT TableName, TableId FROM #tmpTables
    OPEN tables_cur

    FETCH NEXT FROM tables_cur INTO @table_name, @table_id

    WHILE (@@FETCH_STATUS = 0)
    BEGIN           

        -- build query for finding desired columns within current table
        SET @sql_string = 'SELECT COLUMN_NAME as ColumnName From ' + @db_name + '.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''' + @table_name + ''' AND COLUMN_NAME LIKE ''' + @column_filter + ''''

        INSERT INTO #tmpColumns
            EXECUTE(@sql_string)

        -- init the columns cursor to cycle through current matching columns
        DECLARE columns_cur CURSOR FOR SELECT ColumnName FROM #tmpColumns
        OPEN columns_cur

        FETCH NEXT FROM columns_cur INTO @column_name

        WHILE (@@FETCH_STATUS = 0)
        BEGIN                                               
            SET @sql_like_expr = ''

            -- init cursor to cycle through search string for current column
            DECLARE expr_cur CURSOR FOR SELECT SearchString FROM #tmpSearchStrings
            OPEN expr_cur

            FETCH NEXT FROM expr_cur INTO @search_string

            WHILE (@@FETCH_STATUS = 0)
            BEGIN   
                -- build search query expr with output if results are found
                SET @sql_string = 'IF EXISTS (SELECT * FROM [' + @db_name + '].[dbo].[' + @table_name + '] WHERE [' + @column_name + '] LIKE ''%' + @search_string + '%'') PRINT ''' + @db_name + ', ' + @table_name + ', ' + @column_name + ', ' + @search_string + ''''
                EXECUTE(@sql_string)

                FETCH NEXT FROM expr_cur INTO @search_string
            END

            CLOSE expr_cur
            DEALLOCATE expr_cur                 

            FETCH NEXT FROM columns_cur INTO @column_name
        END

        CLOSE columns_cur
        DEALLOCATE columns_cur

        DELETE FROM #tmpColumns

        FETCH NEXT FROM tables_cur INTO @table_name, @table_id
    END

    CLOSE tables_cur
    DEALLOCATE tables_cur

    DELETE FROM #tmpTables

    FETCH NEXT FROM db_cur INTO @db_name, @db_id
END

-- close and deallocate databases cursos
CLOSE db_cur
DEALLOCATE db_cur

-- drop temp tables
DROP TABLE #tmpTables
DROP TABLE #tmpColumns
DROP TABLE #tmpSearchStrings
END
GO
