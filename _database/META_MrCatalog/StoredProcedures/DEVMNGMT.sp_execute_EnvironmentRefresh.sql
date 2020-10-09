SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE   PROCEDURE [DEVMNGMT].[sp_execute_EnvironmentRefresh]
AS
BEGIN

-- LOAD CONFIG VARIABLES
DECLARE 
	@SourceDataEntityID INT
,	@TargetDatabaseID INT
,	@DateFieldID INT
,	@StartDT DATETIME2(7)
,	@EndDT DATETIME2(7)
,	@IsCreateIndexes BIT

-- DERIVED VARIABLES
DECLARE 
    @TargetDatabaseName SYSNAME
,   @SchemaName         SYSNAME
,   @SchemaID           INT
,   @DataEntityName     SYSNAME
,   @SourceDatabaseID   INT
,   @SourceDatabaseName SYSNAME

-- Index Params
DECLARE 
	   @IndexName              VARCHAR(256)
	 , @ColumnName             VARCHAR(100)
	 , @is_unique              VARCHAR(100)
	 , @IndexTypeDesc          VARCHAR(100)
	 , @FileGroupName          VARCHAR(100)
	 , @is_disabled            VARCHAR(100)
	 , @IndexOptions           VARCHAR(MAX)
	 , @IndexColumnId          INT
	 , @IsDescendingKey        INT
	 , @IsIncludedColumn       INT
	 , @TSQLScripCreationIndex VARCHAR(MAX)
	 , @TSQLScripDisableIndex  VARCHAR(MAX)
	 , @IndexColumns           VARCHAR(MAX)
	 , @IncludedColumns        VARCHAR(MAX)

DECLARE 
	   @sql VARCHAR(MAX)
,      @FieldName SYSNAME
,      @sql_where VARCHAR(MAX)

DECLARE refresh_cursor CURSOR FOR
SELECT 
        SourceDataEntityID
    ,   TargetDatabaseID
    ,   DateFieldID
    ,   StartDT
    ,   EndDT
    ,   IsCreateIndexes 
FROM 
    DataManager.DEVMNGMT.EnvironmentRefreshLoadConfig
WHERE IsActive = 1

OPEN refresh_cursor
FETCH NEXT FROM 
    refresh_cursor
INTO 
    @SourceDataEntityID
,   @TargetDatabaseID
,   @DateFieldID
,   @StartDT
,   @EndDT
,   @IsCreateIndexes

WHILE (@@FETCH_STATUS = 0)
BEGIN

	SET @TargetDatabaseName = (SELECT DatabaseName FROM DataManager.DC.[Database] WHERE DatabaseID = @TargetDatabaseID)
	SET @SchemaID = (SELECT SchemaID FROM DataManager.DC.DataEntity WHERE DataEntityID = @SourceDataEntityID)
	SET @SchemaName = (SELECT SchemaName FROM DataManager.DC.[Schema] WHERE SchemaID = @SchemaID)
	SET @DataEntityName = (SELECT DataManager.DC.udf_GetDataEntityNameForDataEntityID(@SourceDataEntityID))

    -- CHECK IF TARGET DATABASE EXISTS, OTHERWISE SKIP THIS ITEM
   IF EXISTS(
                    SELECT 1 FROM sys.databases AS d
                    WHERE d.name = @TargetDatabaseName
            )

    BEGIN
   


   

       -- CHECK IF SCHEMA EXIST ON TARGET DB AND IF NOT CREATE
        SET @sql =  'IF NOT EXISTS( ' + CHAR(13) +
			        CHAR(9) + 'SELECT 1 FROM ' + QUOTENAME(@TargetDatabaseName) + '.' + 'sys.schemas AS s ' + CHAR(13) + 
                    CHAR(9) + 'WHERE s.name = ''' + @SchemaName + ''')' + CHAR(13) + 
                    REPLICATE(CHAR(9),2) + 'EXEC(''USE ' + QUOTENAME(@TargetDatabaseName) + ';' +
                    ' EXEC sp_executesql N''''CREATE SCHEMA ' + @SchemaName + '''''' + ' '')' + CHAR(13) 
        RAISERROR(@sql, 0, 1)
        EXEC(@sql)

	    -- DROP STATEMENT OF EXISTING TABLE
	    SET @sql = 'DROP TABLE IF EXISTS ' + CHAR(13) +
				    QUOTENAME(@TargetDatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) + CHAR(13) 

	    RAISERROR(@sql,0,1)
	    EXEC(@sql)


	    -- CREATE TABLE STATEMENTS
	    EXEC DataManager.DMOD.sp_execute_CreateTableFromDC 
				    @DataEntityID = @SourceDataEntityID
			    ,	@TargetDataBaseName = @TargetDatabaseName
        

        -- IS INDEX CREATION SPECIFIED IN CONFIG?
        IF (@IsCreateIndexes = 1)
        BEGIN
	        -- CREATE INDEX LOGIC
             DECLARE CursorIndex CURSOR FOR
	         SELECT 
		           ix.name AS [IndexName]
		         , CASE
			        WHEN ix.[is_unique] = 1
			            THEN 'UNIQUE '
			            ELSE ''
		            END as [IsUnique]
		         , ix.type_desc AS [TypeDescription]
		         , CASE
							           WHEN ix.[is_padded] = 1
							           THEN 'PAD_INDEX = ON, '
							           ELSE 'PAD_INDEX = OFF, '
						           END + CASE
									         WHEN ix.[allow_page_locks] = 1
									         THEN 'ALLOW_PAGE_LOCKS = ON, '
									         ELSE 'ALLOW_PAGE_LOCKS = OFF, '
								         END + CASE
										           WHEN ix.[allow_row_locks] = 1
										           THEN 'ALLOW_ROW_LOCKS = ON, '
										           ELSE 'ALLOW_ROW_LOCKS = OFF, '
									           END + CASE
												         WHEN INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1
												         THEN 'STATISTICS_NORECOMPUTE = ON, '
												         ELSE 'STATISTICS_NORECOMPUTE = OFF, '
											         END + CASE
													           WHEN ix.[ignore_dup_key] = 1
													           THEN 'IGNORE_DUP_KEY = ON, '
													           ELSE 'IGNORE_DUP_KEY = OFF, '
												           END + 'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor AS VARCHAR(3)) AS [IndexOptions]
		         , ix.[is_disabled] AS [IsDisabled]
		         , FILEGROUP_NAME(ix.[data_space_id]) AS [FileGroupName]
	        FROM 
		        sys.tables AS t
	        INNER JOIN 
		        sys.schemas AS s
		        ON s.schema_id = t.schema_id
	        INNER JOIN
		        sys.indexes AS ix
		        ON t.object_id = ix.object_id
	        WHERE
			        s.name = @SchemaName
		        AND t.name = @DataEntityName
		        AND t.name <> 'sysdiagrams'
		        AND ix.type > 0
		        AND ix.is_primary_key = 0
		        AND ix.is_unique_constraint = 0
		        AND t.is_ms_shipped = 0
	
    
            OPEN CursorIndex

            FETCH NEXT FROM 
                CursorIndex 
            INTO 
	            @IndexName
	        ,   @is_unique
	        ,   @IndexTypeDesc
	        ,   @IndexOptions
	        ,   @is_disabled
	        ,   @FileGroupName

            WHILE(@@FETCH_STATUS = 0)
            BEGIN

                -- Variables to be used in column level cursor
	            SET @IndexColumns = ''
	            SET @IncludedColumns = ''

	            -- GET Additional Index Info from sys at column level
	            DECLARE CursorIndexColumn CURSOR FOR 
                SELECT 
		            c.name
		            , ixc.is_descending_key
		            , ixc.is_included_column
	            FROM 
			            sys.tables AS t
	            INNER JOIN 
		            sys.schemas AS s
		            ON s.schema_id = t.schema_id
	            INNER JOIN
		            sys.indexes AS ix
		            ON t.object_id = ix.object_id
	            INNER JOIN
		            sys.index_columns AS ixc
		            ON ix.object_id = ixc.object_id
		            AND ix.index_id = ixc.index_id
	            INNER JOIN
		            sys.columns AS c
		            ON ixc.object_id = c.object_id
		            AND ixc.column_id = c.column_id
	            WHERE
		            s.name = @SchemaName
		            AND t.name = @DataEntityName
		            AND ix.name = @IndexName
		            AND ix.type > 0
		            AND (
			                ix.[is_primary_key] = 0
			                OR ix.[is_unique_constraint] = 0
                        )

	            OPEN CursorIndexColumn
	            FETCH NEXT FROM 
                    CursorIndexColumn 
                INTO 
                    @ColumnName
	            ,   @IsDescendingKey
	            ,   @IsIncludedColumn

	            WHILE (@@FETCH_STATUS = 0)
	            BEGIN
		            IF @IsIncludedColumn = 0
		            BEGIN
			            SET @IndexColumns = @IndexColumns + @ColumnName + CASE
																              WHEN @IsDescendingKey = 1
																              THEN ' DESC, '
																              ELSE ' ASC, '
															              END
		            END
			            ELSE
		            BEGIN
			            SET @IncludedColumns = @IncludedColumns + @ColumnName + ', '
		            END

	                FETCH NEXT FROM 
                        CursorIndexColumn 
                    INTO 
                        @ColumnName
	                ,   @IsDescendingKey
	                ,   @IsIncludedColumn
	            END

	            CLOSE CursorIndexColumn
	            DEALLOCATE CursorIndexColumn

	            SET @IndexColumns = SUBSTRING(@IndexColumns, 1, LEN(@IndexColumns) - 1)
	            SET @IncludedColumns = CASE
							               WHEN LEN(@IncludedColumns) > 0
							               THEN SUBSTRING(@IncludedColumns, 1, LEN(@IncludedColumns) - 1)
							               ELSE ''
						               END

	            --  print @IndexColumns
	            --  print @IncludedColumns

	            SET @TSQLScripCreationIndex = ''
	            SET @TSQLScripDisableIndex = ''
	            SET @TSQLScripCreationIndex =   'CREATE ' + @is_unique + @IndexTypeDesc + ' INDEX ' + QUOTENAME(@IndexName) + CHAR(13) +
                                                ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) + '(' + @IndexColumns + ') ' + CHAR(13) +
                                                CASE
										            WHEN LEN(@IncludedColumns) > 0
										                THEN CHAR(13) + 'INCLUDE (' + @IncludedColumns + ')'
										            ELSE ''
									            END + CHAR(13) 
                                                + 'WITH (' + @IndexOptions + ') ON ' + QUOTENAME(@FileGroupName) + ';'
    
                RAISERROR(@TSQLScripCreationIndex, 0, 1) WITH NOWAIT
                EXEC(@TSQLScripCreationIndex)

	            IF @is_disabled = 1
	            BEGIN
		            SET @TSQLScripDisableIndex = CHAR(13) + 'ALTER INDEX ' + QUOTENAME(@IndexName) 
                                                 + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) 
                                                 + ' DISABLE;' + CHAR(13)
        
                    RAISERROR(@TSQLScripDisableIndex, 0, 1) WITH NOWAIT
                    EXEC(@TSQLScripDisableIndex)
	            END


	            FETCH NEXT FROM 
                    CursorIndex 
                INTO 
	                @IndexName
	            ,   @is_unique
	            ,   @IndexTypeDesc
	            ,   @IndexOptions
	            ,   @is_disabled
	            ,   @FileGroupName
            END

            CLOSE CursorIndex
            DEALLOCATE CursorIndex
        END

        -- FINALLY LOGIC TO MOVE THE TABLE (DATA)
        -- QUICK WIN HERE, FULLY DESTRUCTIVE MOVE, DROP AND RECREATE, SO WE CAN DO A SELECT * 
        -- TODO: SPECIFY COLUMN LIST
        -- TODO: IDENTITY COLUMNS?
        IF(ISNULL(@DateFieldID,0) = 0)
        BEGIN
            SET @sql_where = ''
        END
        ELSE
        BEGIN
            -- Get the FIeld name date is based on
            SET @FieldName = DataManager.DC.udf_get_FieldName_From_FieldID(@DateFieldID)
       
            -- Build Dynamic WHERE Clause
            IF(ISDATE(CONVERT(varchar(23), @StartDT)) = 1 AND ISDATE(CONVERT(varchar(23),@EndDT)) = 1)
            BEGIN
                SET @sql_where = ' WHERE ' + QUOTENAME(@FieldName) + ' BETWEEN ''' +
                                   CONVERT(VARCHAR, @StartDT) + ''' AND ''' + CONVERT(VARCHAR, @EndDT) + ''''
            END
            ELSE IF(ISDATE(CONVERT(varchar(23), @StartDT)) = 1 AND ISDATE(CONVERT(varchar(23), @EndDT)) != 1)
            BEGIN
                 SET @sql_where = ' WHERE ' + QUOTENAME(@FieldName) + ' >= ''' + CONVERT(VARCHAR, @StartDT) + ''''
            END
            ELSE IF(ISDATE(CONVERT(varchar(23), @StartDT)) != 1 AND ISDATE(CONVERT(varchar(23), @EndDT)) = 1)
            BEGIN
                SET @sql_where = ' WHERE ' + QUOTENAME(@FieldName) + ' <= ''' + CONVERT(VARCHAR, @EndDT) + ''''
            END
            ELSE
            BEGIN
                SET @sql_where = ''
            END
        END

        -- Derives Source Database Name
        SET @SourceDatabaseID = (SELECT DataManager.DC.udf_get_DatabaseID_from_DataEntityID(@SourceDataEntityID))
        SET @SourceDatabaseName = (SELECT DatabaseName FROM DataManager.[DC].[Database] WHERE DatabaseID = @SourceDatabaseID)
    
        -- BUILD THE INSERT INTO STATEMENT
        SET @sql =  ' INSERT INTO ' + QUOTENAME(@TargetDatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) + CHAR(13) + 
                    ' SELECT * FROM ' + QUOTENAME(@SourceDatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) + CHAR(13) + 
                    @sql_where + CHAR(13)
        PRINT 'Copying ' + QUOTENAME(@TargetDatabaseName) + '.' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@DataEntityName) + CHAR(10) + CHAR(13)
        RAISERROR(@sql, 0, 1)
		EXEC(@sql)
    
    END
    ELSE
    BEGIN
        DECLARE @message VARCHAR(MAX) = 'This procedure does not allow for database creation. Please create ' + @TargetDatabaseName + ' before runnning this procedure.'
        RAISERROR(@message,0,1)
    END

        FETCH NEXT FROM 
            refresh_cursor
        INTO 
            @SourceDataEntityID
        ,   @TargetDatabaseID
        ,   @DateFieldID
        ,   @StartDT
        ,   @EndDT
        ,   @IsCreateIndexes

    END


CLOSE refresh_cursor
DEALLOCATE refresh_cursor

END

GO
