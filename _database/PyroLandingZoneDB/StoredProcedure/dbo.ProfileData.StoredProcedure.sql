SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ProfileData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[ProfileData] AS' 
END
GO

/*
EXEC [dbo].[ProfileData] 
					   @Report = 1 -- 'ColumnDataProfiling'
                      ,@SchemaName = 'AdventureWorks'
					  ,@ObjectlisttoSearch = N''
					  ,@ExcludeTables = N''
					  ,@ExcludeColumns = N''
					  ,@ExcludeDataType = N''
					  ,@RestrictCharlength = N'' 
					  ,@RestrictNoOfUniqueValues = N'' 

EXEC [dbo].[ProfileData] 
					   @Report = 2 --'ColumnUniqueValues'
                      ,@SchemaName = 'AdventureWorks'
					  ,@ObjectlisttoSearch = N''
					  ,@ExcludeTables = N''
					  ,@ExcludeColumns = N''
					  ,@ExcludeDataType = N''
					  ,@RestrictCharlength = N'' 
					  ,@RestrictNoOfUniqueValues = N'' 
*/

ALTER   PROCEDURE [dbo].[ProfileData] @Report                   TINYINT, --1 = 'ColumnDataProfiling', 2 = 'ColumnUniqueValues' 
                                                      @SchemaName               NVARCHAR(MAX) = N'', 
                                                      @ObjectlisttoSearch       NVARCHAR(MAX), 
                                                      @ExcludeTables            NVARCHAR(MAX) = N'', 
                                                      @ExcludeColumns           NVARCHAR(MAX) = N'', 
                                                      @ExcludeDataType          NVARCHAR(100) = N'', 
                                                      @RestrictCharlength       INT, 
                                                      @RestrictNoOfUniqueValues INT
AS
    BEGIN
        SET NOCOUNT ON;
        SET ANSI_WARNINGS OFF;
        SET ANSI_NULLS ON;
        
		DECLARE 
			@sql_execute BIT= 1
		,	@sql_debug BIT= 1
		,	@sql_log BIT
		,	@sql_statement NVARCHAR(MAX)
		,	@sql_parameter NVARCHAR(MAX)
		,	@sql_message NVARCHAR(MAX)
		,	@sql_crlf NVARCHAR(2)= CHAR(13) + CHAR(10)
		,	@cursor_ddl CURSOR;

        SELECT @RestrictCharlength = IIF(@RestrictCharlength IS NULL
                                         OR @RestrictCharlength = ''
											, 100
											, @RestrictCharlength
									 );

        SELECT @RestrictNoOfUniqueValues = IIF(@RestrictNoOfUniqueValues IS NULL
                                               OR @RestrictNoOfUniqueValues = ''
													, 50
													, @RestrictNoOfUniqueValues
											);
        DECLARE @TableColList TABLE (
			Id      INT IDENTITY(1, 1), 
			Tbl     NVARCHAR(128), 
			colname NVARCHAR(200), 
			ColType NVARCHAR(150)
        );

        IF ISNULL(@SchemaName, '') != ''
           OR ISNULL(@ObjectlisttoSearch, '') != ''
            BEGIN
                INSERT INTO @TableColList
                       SELECT DISTINCT 
                              CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) TableName, 
                              C.Name,
                              CASE
                                  WHEN TY.is_user_defined = 1
                                  THEN
                       (
                           SELECT Name
                           FROM sys.types
                           WHERE system_type_id = user_type_id
                                 AND system_type_id = TY.system_type_id
                       )
                                  ELSE TY.Name
                              END
                       FROM sys.tables T
                            JOIN sys.columns C ON T.object_id = C.object_id
                            JOIN sys.types TY ON C.[user_type_id] = TY.[user_type_id]
                       -- Ignore the datatypes that are not required 
                       WHERE TY.Name NOT IN('geography', 'varbinary', 'binary', 'text', 'ntext', 'image', 'hierarchyid', 'xml', 'sql_variant')
                            AND (SCHEMA_NAME(T.schema_id) IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@SchemaName, ',')
                       )
                                 OR CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ObjectlisttoSearch, ',')
                       ))
                            AND (TY.Name NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeDataType, ',')
                       )
                                 AND TY.Name = TY.Name)
                            AND (C.Name NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeColumns, ',')
                       )
                                 AND C.Name = C.Name)
                            AND (CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeTables, ',')
                       )
                                 AND CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) = CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name));
        END;
            ELSE
            BEGIN
                INSERT INTO @TableColList
                       SELECT DISTINCT 
                              CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) TableName, 
                              C.Name,
                              CASE
                                  WHEN TY.is_user_defined = 1
                                  THEN
                       (
                           SELECT Name
                           FROM sys.types
                           WHERE system_type_id = user_type_id
                                 AND system_type_id = TY.system_type_id
                       )
                                  ELSE TY.Name
                              END
                       FROM sys.tables T
                            JOIN sys.columns C ON T.object_id = C.object_id
                            JOIN sys.types TY ON C.[user_type_id] = TY.[user_type_id]
                       -- Ignore the datatypes that are not required 
                       WHERE TY.Name NOT IN('geography', 'varbinary', 'binary', 'text', 'ntext', 'image', 'hierarchyid', 'xml', 'sql_variant')
                            AND (TY.Name NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeDataType, ',')
                       )
                                 AND TY.Name = TY.Name)
                            AND (C.Name NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeColumns, ',')
                       )
                                 AND C.Name = C.Name)
                            AND (CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) NOT IN
                       (
                           SELECT value
                           FROM STRING_SPLIT(@ExcludeTables, ',')
                       )
                                 AND CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name) = CONCAT(SCHEMA_NAME(T.schema_id), '.', T.Name));
        END;
        DROP TABLE IF EXISTS ##Final;
        CREATE TABLE ##Final
        (Id                    BIGINT IDENTITY(1, 1), 
         TableName             NVARCHAR(128), 
         ColumnName            NVARCHAR(200), 
         ColumnType            NVARCHAR(150), 
         ColumnUniqueValues    NVARCHAR(MAX), 
         UniqueValueOccurance  BIGINT, 
         MissingDataRowCount   BIGINT, 
         MinValue              NVARCHAR(MAX), 
         MaxValue              NVARCHAR(MAX), 
         SpecialCharacters     BIGINT, 
         LeadingTrailingSpaces BIGINT, 
         MinFieldValueLen      BIGINT, 
         MaxFieldValueLen      BIGINT, 
         UniqueValue           BIGINT
        );
        DROP TABLE IF EXISTS #temp;
        CREATE TABLE #temp
        (Id                    BIGINT IDENTITY(1, 1), 
         TableName             NVARCHAR(128), 
         ColumnName            NVARCHAR(200), 
         Cnt                   BIGINT, 
         MaxLen                BIGINT, 
         MinLen                BIGINT, 
         MissingDataCount      BIGINT, 
         MinValue              NVARCHAR(MAX), 
         MaxValue              NVARCHAR(MAX), 
         SpecialCharacters     BIGINT, 
         LeadingTrailingSpaces BIGINT
        );
        DECLARE @I INT= 1, @SQL NVARCHAR(MAX)= N'', @tblname NVARCHAR(128), @Colname NVARCHAR(200), @ColType NVARCHAR(150), @Cnt BIGINT, @MaxLen BIGINT, @MinLen BIGINT, @MissingData BIGINT, @MaxVal NVARCHAR(MAX)= N'', @MinVal NVARCHAR(MAX)= N'', @MinMAxSQL NVARCHAR(MAX)= N'', @SpecialCharacters BIGINT, @LeadingTrailingSpaces BIGINT;
        WHILE @I <=
        (
            SELECT MAX(Id)
            FROM @TableColList
        )
            BEGIN
                SELECT @Colname = QUOTENAME(colname), 
                       @tblname = Tbl, 
                       @ColType = ColType
                FROM @TableColList
                WHERE Id = @I;
                SELECT @MinMAxSQL = CASE
                                        WHEN @ColType IN('date', 'datetime', 'datetime2', 'datetimeoffset', 'time', 'timestamp')
                                        THEN CONCAT(' FORMAT (MIN(', @Colname, '), ''yyyy-MM-dd,hh:mm:ss'') MinValue,FORMAT (MAX(', @Colname, '), ''yyyy-MM-dd,hh:mm:ss'') MAXValue')
                                        WHEN @ColType = 'bit'
                                        THEN '0 AS MinValue,1 AS MaxValue'
                                        ELSE CONCAT('CASE WHEN EXISTS (SELECT 1 FROM ', @tblname, ' WHERE ISNUMERIC(', @Colname, ') = 0)', 'THEN NULL ELSE MIN(', @Colname, ')   END MinValue
				             ,CASE WHEN EXISTS (SELECT 1 FROM ', @tblname, ' WHERE ISNUMERIC(', @Colname, ') = 0)', 'THEN NULL ELSE MAX(', @Colname, ')   END MAXValue')
                                    END;
                EXEC (';WITH CTE AS (
		SELECT   COUNT_BIG(DISTINCT '+@Colname+') Cnt
				,MAX(LEN('+@Colname+')) MaxLen
				,MIN(LEN('+@Colname+')) MinLen
				,SUM(CASE WHEN '+@Colname+' IS NULL OR CAST('+@Colname+' AS VARCHAR(MAX)) = '''' THEN 1 ELSE 0 END) MissingData
				,'+@MinMAxSQL+'
				,CASE WHEN '''+@ColType+''' IN (''nvarchar'',''varchar'',''nchar'',''char'') 
				      THEN SUM(CASE WHEN '+@Colname+' LIKE ''%[^a-zA-Z0-9 ]%'' THEN 1 ELSE 0 END) 
					  ELSE NULL END SpecialCharacters
				,CASE WHEN '''+@ColType+''' IN (''nvarchar'',''varchar'',''nchar'',''char'') 
				      THEN SUM(CASE WHEN ISNULL(DATALENGTH('+@Colname+'),'''') = ISNULL(DATALENGTH(RTRIM(LTRIM('+@Colname+'))),'''') THEN 0 ELSE 1 END) 
					  ELSE NULL END LeadingTrailingSpaces
		FROM '+@tblname+' )
		INSERT #temp(TableName,ColumnName,Cnt,MaxLen,MinLen,MissingDataCount,MinValue,MaxValue,SpecialCharacters,LeadingTrailingSpaces)
		SELECT '''+@tblname+''','''+@Colname+''',Cnt,ISNULL(MaxLen,0) MaxLen,ISNULL(MinLen,0) MinLen,ISNULL(MissingData,0) MissingData,MinValue,MAXValue
		,ISNULL(SpecialCharacters,0) SpecialCharacters,ISNULL(LeadingTrailingSpaces,0) LeadingTrailingSpaces FROM CTE');
                SELECT @Cnt = Cnt, 
                       @MaxLen = MaxLen, 
                       @MinLen = MinLen, 
                       @MissingData = MissingDataCount, 
                       @MinVal = MinValue, 
                       @MaxVal = MaxValue, 
                       @SpecialCharacters = SpecialCharacters, 
                       @LeadingTrailingSpaces = LeadingTrailingSpaces
                FROM #temp
                WHERE Id = @I
                      AND TableName = @tblname
                      AND ColumnName = @Colname;
                IF ISNULL(@MaxLen, '') < @RestrictCharlength
                   AND ISNULL(@Cnt, '') < @RestrictNoOfUniqueValues
                    BEGIN
                        SET @SQL = CONCAT('SELECT ''', @tblname, ''',''', @Colname, ''',''', @ColType, ''',', @Colname, ',COUNT_BIG(', @Colname, '),', @MissingData, ',''', @MinVal, ''',''', @MaxVal, ''',', @SpecialCharacters, ',', @LeadingTrailingSpaces, ',', @MinLen, ',', @MaxLen, ',', '''', @Cnt, '''', ' FROM ', @tblname, ' GROUP BY ', @Colname);
                        INSERT INTO ##Final
                        (TableName, 
                         ColumnName, 
                         ColumnType, 
                         ColumnUniqueValues, 
                         UniqueValueOccurance, 
                         MissingDataRowCount, 
                         MinValue, 
                         MaxValue, 
                         SpecialCharacters, 
                         LeadingTrailingSpaces, 
                         MinFieldValueLen, 
                         MaxFieldValueLen, 
                         UniqueValue
                        )
                        EXEC (@SQL);
                END;
                    ELSE
                    BEGIN
                        INSERT INTO ##Final
                        (TableName, 
                         ColumnName, 
                         ColumnType, 
                         MissingDataRowCount, 
                         MinValue, 
                         MaxValue, 
                         SpecialCharacters, 
                         LeadingTrailingSpaces, 
                         MinFieldValueLen, 
                         MaxFieldValueLen, 
                         UniqueValue
                        )
                               SELECT @tblname, 
                                      @Colname, 
                                      @ColType, 
                                      @MissingData, 
                                      @MinVal, 
                                      @MaxVal, 
                                      @SpecialCharacters, 
                                      @LeadingTrailingSpaces, 
                                      @MinLen, 
                                      @MaxLen, 
                                      @Cnt;
                END;
                SET @I = @I + 1;
            END;
        IF @Report = 1
            BEGIN
                SELECT DISTINCT 
                       TableName, 
                       ColumnName, 
                       ColumnType, 
                       MissingDataRowCount, 
                       MinValue, 
                       MaxValue, 
                       SpecialCharacters, 
                       LeadingTrailingSpaces, 
                       MinFieldValueLen, 
                       MaxFieldValueLen, 
                       UniqueValue
                FROM ##Final
                ORDER BY TableName, 
                         ColumnName;
        END;
        IF @Report = 2
            BEGIN
                SELECT TableName, 
                       ColumnName, 
                       ColumnUniqueValues, 
                       UniqueValueOccurance, 
                       UniqueValue
                FROM ##Final
                ORDER BY TableName, 
                         ColumnName;
        END;
    END;


	--SELECT * 
	--INTO dbo.DataProfile_UniqueValues
	--FROM ##Final

	--DROP TABLE ##Final

	--UPDATE dbo.DataProfile_UniqueValues
	--SET UniqueValue = REPLACE(UniqueValue, 'This field has Unique values = ', '')

	--ALTER TABLE dbo.DataProfile_UniqueValues
	--ALTER COLUMN UniqueValue BIGINT NULL
GO
