SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[meta].[sp_GetDDL]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [meta].[sp_GetDDL] AS' 
END
GO
ALTER    PROCEDURE [meta].[sp_GetDDL]
  @TBL                VARCHAR(255),
      @FINALSQL               VARCHAR(MAX) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE     @TBLNAME                VARCHAR(200),
              @SCHEMANAME             VARCHAR(255),
              @STRINGLEN              INT,
              @TABLE_ID               INT,          
              @CONSTRAINTSQLS         VARCHAR(MAX),
              @CHECKCONSTSQLS         VARCHAR(MAX),
              @RULESCONSTSQLS         VARCHAR(MAX),
              @FKSQLS                 VARCHAR(MAX),
              @TRIGGERSTATEMENT       VARCHAR(MAX),
              @EXTENDEDPROPERTIES     VARCHAR(MAX),
              @INDEXSQLS              VARCHAR(MAX),
              @MARKSYSTEMOBJECT       VARCHAR(MAX),
              @vbCrLf                 CHAR(2),
              @ISSYSTEMOBJECT         INT,
              @PROCNAME               VARCHAR(256),
              @input                  VARCHAR(MAX),
              @ObjectTypeFound        VARCHAR(255),
              @ObjectDataTypeLen      INT;

--##############################################################################
-- INITIALIZE
--##############################################################################
  SET @input = '';
  --new code: determine whether this proc is marked as a system proc with sp_ms_marksystemobject,
  --which flips the is_ms_shipped bit in sys.objects
  --  SELECT @ISSYSTEMOBJECT = ISNULL(is_ms_shipped,0),@PROCNAME = ISNULL(name,'##sp_GetDDLa') FROM sys.objects WHERE OBJECT_ID = @@PROCID
  --IF @ISSYSTEMOBJECT IS NULL 
  --  SELECT @ISSYSTEMOBJECT = ISNULL(is_ms_shipped,0),@PROCNAME = ISNULL(name,'##sp_GetDDLa') FROM master.sys.objects WHERE OBJECT_ID = @@PROCID
  --IF @ISSYSTEMOBJECT IS NULL 
  --  SET @ISSYSTEMOBJECT = 0  
  --IF @PROCNAME IS NULL
    SET @PROCNAME = '##sp_GetDDLa';
  --SET @TBL =  '[adf].[WHATEVER1]'
  --does the tablename contain a schema?
  SET @vbCrLf =  CHAR(10);
  SELECT @SCHEMANAME = ISNULL(PARSENAME(@TBL,2),'adf') ,
         @TBLNAME    = PARSENAME(@TBL,1);
  SELECT
    @TBLNAME    = [OBJS].[name],
    @TABLE_ID   = [OBJS].[object_id]
  FROM [sys].[objects] [OBJS]
  WHERE [OBJS].[type]          IN ('S','U')
    AND [OBJS].[name]          <>  'dtproperties'
    AND [OBJS].[name]           =  @TBLNAME
    AND [OBJS].[schema_id] =  SCHEMA_ID(@SCHEMANAME) ;

 SELECT @ObjectDataTypeLen = MAX(LEN([name])) FROM [sys].[types];
--##############################################################################
-- Check If TEMP TableName is Valid
--##############################################################################
  IF LEFT(@TBLNAME,1) = '#'  COLLATE SQL_Latin1_General_CP1_CI_AS
    BEGIN
      PRINT '--TEMP TABLE  ' + quotename(@TBLNAME) + '  FOUND';
      IF OBJECT_ID('tempdb..' + quotename(@TBLNAME)) IS NOT NULL
        BEGIN
          PRINT '--GOIN TO TEMP PROCESSING';
          GOTO TEMPPROCESS;
        END;
    END;
  ELSE
    BEGIN
      PRINT '--Non-Temp Table, ' + quotename(@TBLNAME) + ' continue Processing';
    END;
--##############################################################################
-- Check If TableName is Valid
--##############################################################################
  IF ISNULL(@TABLE_ID,0) = 0
    BEGIN
      --V309 code: see if it is an object and not a table.
      SELECT
        @TBLNAME    = [OBJS].[name],
        @TABLE_ID   = [OBJS].[object_id],
        @ObjectTypeFound = [OBJS].[type_desc]
      FROM [sys].[objects] [OBJS]
      --WHERE [type_desc]     IN('SQL_STORED_PROCEDURE','VIEW','SQL_TRIGGER','AGGREGATE_FUNCTION','SQL_INLINE_TABLE_VALUED_FUNCTION','SQL_TABLE_VALUED_FUNCTION','SQL_SCALAR_FUNCTION','SYNONYMN')
      WHERE [OBJS].[type]          IN ('P','V','TR','AF','IF','FN','TF','SN')
        AND [OBJS].[name]          <>  'dtproperties'
        AND [OBJS].[name]           =  @TBLNAME
        AND [OBJS].[schema_id] =  SCHEMA_ID(@SCHEMANAME) ;
      IF ISNULL(@TABLE_ID,0) <> 0  
        BEGIN
          --adding a drop statement.
          --adding a sp_ms_marksystemobject if needed

          SELECT @MARKSYSTEMOBJECT = CASE 
                                       WHEN [OBJS].[is_ms_shipped] = 1 
                                       THEN '
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  ''' + quotename(@SCHEMANAME) +'.' + quotename(@TBLNAME) + '''
--#################################################################################################
' 
                                       ELSE '
GO
' 
                                     END 
          FROM [sys].[objects] [OBJS] 
          WHERE [OBJS].[object_id] = @TABLE_ID;

          --adding a drop statement.
          --adding a drop statement.
          IF @ObjectTypeFound = 'SYNONYM'  COLLATE SQL_Latin1_General_CP1_CI_AS
            BEGIN
               SELECT @FINALSQL = 
                'IF EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                                + [name] 
                                + ''''
                                + ' AND base_object_name <> ''' + [base_object_name] + ''')'
                                + @vbCrLf
                                + '  DROP SYNONYM ' + QUOTENAME([name]) + ''
                                + @vbCrLf
                                +'GO'
                                + @vbCrLf
                                +'IF NOT EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                                + [name] 
                                + ''')'
                                + @vbCrLf
                                + 'CREATE SYNONYM ' + QUOTENAME([name]) + ' FOR ' + [base_object_name] +';'
                                from [sys].[synonyms]
                                WHERE  [name]   =  @TBLNAME
                                AND [SCHEMA_ID] =  SCHEMA_ID(@SCHEMANAME);
            END;
          ELSE
            BEGIN
          SELECT @FINALSQL = 
          'IF OBJECT_ID(''' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
          + 'DROP ' + CASE 
                        WHEN [OBJS].[type] IN ('P')
                        THEN ' PROCEDURE '
                        WHEN [OBJS].[type] IN ('V')
                        THEN ' VIEW      '
                        WHEN [OBJS].[type] IN ('TR')
                        THEN ' TRIGGER   '
                        ELSE ' FUNCTION  '
                      END 
                      + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf + 'GO' + @vbcrlf
          + [def].[definition] + @MARKSYSTEMOBJECT
          FROM [sys].[objects] [OBJS] 
            INNER JOIN [sys].[sql_modules] [def]
              ON [OBJS].[object_id] = [def].[object_id]
          WHERE [OBJS].[type]          IN ('P','V','TR','AF','IF','FN','TF')
            AND [OBJS].[name]          <>  'dtproperties'
            AND [OBJS].[name]           =  @TBLNAME
            AND [OBJS].[schema_id] =  SCHEMA_ID(@SCHEMANAME) ;
            END;
          SET @input = @FINALSQL  
            --ten years worth of days from todays date:
         ;WITH [E01]([N]) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL
                          SELECT 1 UNION ALL SELECT 1 UNION ALL
                          SELECT 1 UNION ALL SELECT 1 UNION ALL
                          SELECT 1 UNION ALL SELECT 1 UNION ALL
                          SELECT 1 UNION ALL SELECT 1), --         10 or 10E01 rows
               [E02]([N]) AS (SELECT 1 FROM [E01] [a], [E01] [b]),  --        100 or 10E02 rows
               [E04]([N]) AS (SELECT 1 FROM [E02] [a], [E02] [b]),  --     10,000 or 10E04 rows
               [E08]([N]) AS (SELECT 1 FROM [E04] [a], [E04] [b]),  --100,000,000 or 10E08 rows
               --E16(N) AS (SELECT 1 FROM E08 a, E08 b),  --10E16 or more rows than you'll EVER need,
               [Tally]([N]) AS (SELECT ROW_NUMBER() OVER (ORDER BY [E08].[N]) FROM [E08]),
             [ItemSplit](
                       [ItemOrder],
                       [Item]
                      ) AS (
                            SELECT [Tally].[N],
                              SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf),CHARINDEX(@vbCrLf,@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf)) - [Tally].[N] - DATALENGTH(@vbCrLf))
                            FROM [Tally]
                            WHERE [Tally].[N] < DATALENGTH(@vbCrLf + @input)
                            --WHERE N < DATALENGTH(@vbCrLf + @input) -- REMOVED added @vbCrLf
                              AND SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N],DATALENGTH(@vbCrLf)) = @vbCrLf --Notice how we find the delimiter
                           )
        SELECT
          --row_number() over (order by ItemOrder) as ItemID,
          [ItemSplit].[Item]
        FROM [ItemSplit];
         RETURN 0;
        END;
      --ELSE
      --  BEGIN
      --  SET @FINALSQL = 'Object ' + quotename(@SCHEMANAME) + '.' + quotename(@TBLNAME) + ' does not exist in Database ' + quotename(DB_NAME())   + ' '  
      --                + CASE 
      --                    WHEN @ISSYSTEMOBJECT = 0 THEN @vbCrLf + ' (also note that ' + @PROCNAME + ' is not marked as a system proc and cross db access to sys.tables will fail.)'
      --                    ELSE ''
      --                  END
      --IF LEFT(@TBLNAME,1) = '#' 
      --  SET @FINALSQL = @FINALSQL + ' OR in The tempdb database.'
      --SELECT @FINALSQL AS Item;
      --RETURN 0
      --  END  
      
    END;
--##############################################################################
-- Valid Table, Continue Processing
--##############################################################################
 SELECT 
   @FINALSQL =  'IF OBJECT_ID(''' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
              + 'DROP TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf /*'+ GO'*/ + @vbcrlf
              + 'CREATE TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ( ';
  --removed invalid code here which potentially selected wrong table--thanks David Grifiths @SSC!
  SELECT
    @STRINGLEN = MAX(LEN([COLS].[name])) + 1
  FROM [sys].[objects] [OBJS]
    INNER JOIN [sys].[columns] [COLS]
      ON  [OBJS].[object_id] = [COLS].[object_id]
      AND [OBJS].[object_id] = @TABLE_ID;
--##############################################################################
--Get the columns, their definitions and defaults.
--##############################################################################
  SELECT
    @FINALSQL = @FINALSQL
    + CASE
        WHEN [COLS].[is_computed] = 1
        THEN @vbCrLf
             + QUOTENAME([COLS].[name])
             + ' '
             + SPACE(@STRINGLEN - LEN([COLS].[name]))
             + 'AS ' + ISNULL([CALC].[definition],'')
             + CASE 
                 WHEN [CALC].[is_persisted] = 1 
                 THEN ' PERSISTED'
                 ELSE ''
               END
        ELSE @vbCrLf
             + QUOTENAME([COLS].[name])
             + ' '
             + SPACE(@STRINGLEN - LEN([COLS].[name]))
             + UPPER(TYPE_NAME([COLS].[user_type_id]))
             + CASE
-- data types with precision and scale  IE DECIMAL(18,3), NUMERIC(10,2)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('decimal','numeric')
               THEN '('
                    + CONVERT(VARCHAR,[COLS].[precision])
                    + ','
                    + CONVERT(VARCHAR,[COLS].[scale])
                    + ') '
                    + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[precision])
                    + ','
                    + CONVERT(VARCHAR,[COLS].[scale])))
                    + SPACE(7)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + CASE
                        WHEN COLUMNPROPERTY ( @TABLE_ID , [COLS].[name] , 'IsIdentity' ) = 0
                        THEN ''
                        ELSE ' IDENTITY('
                               + CONVERT(VARCHAR,ISNULL(IDENT_SEED(@TBLNAME),1) )
                               + ','
                               + CONVERT(VARCHAR,ISNULL(IDENT_INCR(@TBLNAME),1) )
                               + ')'
                        END
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
-- data types with scale  IE datetime2(7),TIME(7)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('datetime2','datetimeoffset','time')
               THEN CASE 
                      WHEN [COLS].[scale] < 7 THEN
                      '('
                      + CONVERT(VARCHAR,[COLS].[scale])
                      + ') '
                    ELSE 
                      '    '
                    END
                    + SPACE(4)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + '        '
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--data types with no/precision/scale,IE  FLOAT
               WHEN  TYPE_NAME([COLS].[user_type_id]) IN ('float') --,'real')
               THEN
               --addition: if 53, no need to specifically say (53), otherwise display it
                    CASE
                      WHEN [COLS].[precision] = 53
                      THEN SPACE(11 - LEN(CONVERT(VARCHAR,[COLS].[precision])))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,[COLS].[precision])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[precision])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      END
--data type with max_length		ie CHAR (44), VARCHAR(40), BINARY(5000),
--##############################################################################
-- COLLATE STATEMENTS
-- personally i do not like collation statements,
-- but included here to make it easy on those who do
--##############################################################################
               WHEN  TYPE_NAME([COLS].[user_type_id]) IN ('char','varchar','binary','varbinary')
               THEN CASE
                      WHEN  [COLS].[max_length] = -1
                      THEN  '(max)'
                            + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[max_length])))
                            + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                            ----collate to comment out when not desired
                            --+ CASE
                            --    WHEN COLS.collation_name IS NULL
                            --    THEN ''
                            --    ELSE ' COLLATE ' + COLS.collation_name
                            --  END
                            + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN [COLS].[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
                      ELSE '('
                           + CONVERT(VARCHAR,[COLS].[max_length])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[max_length])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--data type with max_length ( BUT DOUBLED) ie NCHAR(33), NVARCHAR(40)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('nchar','nvarchar')
               THEN CASE
                      WHEN  [COLS].[max_length] = -1
                      THEN '(max)'
                           + SPACE(5 - LEN(CONVERT(VARCHAR,([COLS].[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN  ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,([COLS].[max_length] / 2))
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,([COLS].[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END

               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('datetime','money','text','image','real')
               THEN SPACE(18 - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + '              '
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--  other data type 	IE INT, DATETIME, MONEY, CUSTOM DATA TYPE,...
               ELSE SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                            + CASE
                                WHEN COLUMNPROPERTY ( @TABLE_ID , [COLS].[name] , 'IsIdentity' ) = 0
                                THEN '              '
                                ELSE ' IDENTITY('
                                     + CONVERT(VARCHAR,ISNULL(IDENT_SEED(@TBLNAME),1) )
                                     + ','
                                     + CONVERT(VARCHAR,ISNULL(IDENT_INCR(@TBLNAME),1) )
                                     + ')'
                              END
                            + SPACE(2)
                            + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN [COLS].[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
               END
             + CASE
                 WHEN [COLS].[default_object_id] = 0
                 THEN ''
                 --ELSE ' DEFAULT '  + ISNULL(def.[definition] ,'')
                 --optional section in case NAMED default constraints are needed:
                 ELSE '  CONSTRAINT ' + quotename([DEF].[name]) + ' DEFAULT ' + ISNULL([DEF].[definition] ,'')
                        --i thought it needed to be handled differently! NOT!
               END  --CASE cdefault
      END --iscomputed
    + ','
    FROM [sys].[columns] [COLS]
      LEFT OUTER JOIN  [sys].[default_constraints]  [DEF]
        ON [COLS].[default_object_id] = [DEF].[object_id]
      LEFT OUTER JOIN [sys].[computed_columns] [CALC]
         ON  [COLS].[object_id] = [CALC].[object_id]
         AND [COLS].[column_id] = [CALC].[column_id]
    WHERE [COLS].[object_id]=@TABLE_ID
    ORDER BY [COLS].[column_id];
--##############################################################################
--used for formatting the rest of the constraints:
--##############################################################################
  SELECT
    @STRINGLEN = MAX(LEN([OBJS].[name])) + 1
  FROM [sys].[objects] [OBJS];
--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
  DECLARE @Results  TABLE (
                    [SCHEMA_ID]             INT,
                    [SCHEMA_NAME]           VARCHAR(255),
                    [OBJECT_ID]             INT,
                    [OBJECT_NAME]           VARCHAR(255),
                    [index_id]              INT,
                    [index_name]            VARCHAR(255),
                    [ROWS]                  BIGINT,
                    [SizeMB]                DECIMAL(19,3),
                    [IndexDepth]            INT,
                    [TYPE]                  INT,
                    [type_desc]             VARCHAR(30),
                    [fill_factor]           INT,
                    [is_unique]             INT,
                    [is_primary_key]        INT ,
                    [is_unique_constraint]  INT,
                    [index_columns_key]     VARCHAR(MAX),
                    [index_columns_include] VARCHAR(MAX),
                    [has_filter] bit ,
                    [filter_definition] VARCHAR(MAX),
                    [currentFilegroupName]  varchar(128),
                    [CurrentCompression]    varchar(128));
  INSERT INTO @Results
    SELECT
      [SCH].[schema_id], [SCH].[name] AS [SCHEMA_NAME],
      [OBJS].[object_id], [OBJS].[name] AS [OBJECT_NAME],
      [IDX].[index_id], ISNULL([IDX].[name], '---') AS [index_name],
      [partitions].[ROWS], [partitions].[SizeMB], INDEXPROPERTY([OBJS].[object_id], [IDX].[name], 'IndexDepth') AS [IndexDepth],
      [IDX].[type], [IDX].[type_desc], [IDX].[fill_factor],
      [IDX].[is_unique], [IDX].[is_primary_key], [IDX].[is_unique_constraint],
      ISNULL([Index_Columns].[index_columns_key], '---') AS [index_columns_key],
      ISNULL([Index_Columns].[index_columns_include], '---') AS [index_columns_include],
      [IDX].[has_filter],
      [IDX].[filter_definition],
      [filz].[name],
      ISNULL([p].[data_compression_desc],'')
    FROM [sys].[objects] [OBJS]
      INNER JOIN [sys].[schemas] [SCH] ON [OBJS].[schema_id]=[SCH].[schema_id]
      INNER JOIN [sys].[indexes] [IDX] ON [OBJS].[object_id]=[IDX].[object_id]
      INNER JOIN [sys].[filegroups] [filz] ON [IDX].[data_space_id] = [filz].[data_space_id]
      INNER JOIN [sys].[partitions] [p]     ON  [IDX].[object_id] =  [p].[object_id]  AND [IDX].[index_id] = [p].[index_id]
      INNER JOIN (
                  SELECT
                    [STATS].[object_id], [STATS].[index_id], SUM([STATS].[row_count]) AS [ROWS],
                    CONVERT(NUMERIC(19,3), CONVERT(NUMERIC(19,3), SUM([STATS].[in_row_reserved_page_count]+[STATS].[lob_reserved_page_count]+[STATS].[row_overflow_reserved_page_count]))/CONVERT(NUMERIC(19,3), 128)) AS [SizeMB]
                  FROM [sys].[dm_db_partition_stats] [STATS]
                  GROUP BY [STATS].[object_id], [STATS].[index_id]
                 ) AS [partitions] 
        ON  [IDX].[object_id]=[partitions].[OBJECT_ID] 
        AND [IDX].[index_id]=[partitions].[index_id]

    CROSS APPLY (
                 SELECT
                   LEFT([Index_Columns].[index_columns_key], LEN([Index_Columns].[index_columns_key])-1) AS [index_columns_key],
                  LEFT([Index_Columns].[index_columns_include], LEN([Index_Columns].[index_columns_include])-1) AS [index_columns_include]
                 FROM
                      (
                       SELECT
                              (
                              SELECT QUOTENAME([COLS].[name]) + CASE WHEN [IXCOLS].[is_descending_key] = 0 THEN ' asc' ELSE ' desc' END + ',' + ' '
                               FROM [sys].[index_columns] [IXCOLS]
                                 INNER JOIN [sys].[columns] [COLS]
                                   ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                   AND [IXCOLS].[object_id] = [COLS].[object_id]
                               WHERE [IXCOLS].[is_included_column] = 0
                                 AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                 AND [IDX].[index_id] = [IXCOLS].[index_id]
                               ORDER BY [IXCOLS].[key_ordinal]
                               FOR XML PATH('')
                              ) AS [index_columns_key],
                             (
                             SELECT QUOTENAME([COLS].[name]) + ',' + ' '
                              FROM [sys].[index_columns] [IXCOLS]
                                INNER JOIN [sys].[columns] [COLS]
                                  ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                  AND [IXCOLS].[object_id] = [COLS].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 1
                                AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[index_column_id]
                              FOR XML PATH('')
                             ) AS [index_columns_include]
                      ) AS [Index_Columns]
                ) AS [Index_Columns]
    WHERE [SCH].[name]  LIKE CASE 
                                     WHEN @SCHEMANAME = ''   COLLATE SQL_Latin1_General_CP1_CI_AS
                                     THEN [SCH].[name] 
                                     ELSE @SCHEMANAME 
                                   END
    AND [OBJS].[name] LIKE CASE 
                                  WHEN @TBLNAME = ''   COLLATE SQL_Latin1_General_CP1_CI_AS 
                                  THEN [OBJS].[name] 
                                  ELSE @TBLNAME 
                                END
    ORDER BY 
      [SCH].[name], 
      [OBJS].[name], 
      [IDX].[name];
--@Results table has both PK,s Uniques and indexes in thme...pull them out for adding to funal results:
  SET @CONSTRAINTSQLS = '';
  SET @INDEXSQLS      = '';

--##############################################################################
--constriants
--column store indexes are different: the "include" columns for normal indexes as scripted above are the columnstores indexed columns
--add a CASE for that situation.
--##############################################################################
  SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS 
         + CASE
             WHEN [is_primary_key] = 1 OR [is_unique] = 1
             THEN @vbCrLf
                  + 'CONSTRAINT   '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' '
                  + CASE  
                      WHEN [is_primary_key] = 1 
                      THEN ' PRIMARY KEY ' 
                      ELSE CASE  
                             WHEN [is_unique] = 1     
                             THEN ' UNIQUE      '      
                             ELSE '' 
                           END 
                    END
                  + [type_desc] 
                  + CASE 
                      WHEN [type_desc]='NONCLUSTERED' 
                      THEN '' 
                      ELSE '   ' 
                    END
                  + ' (' + [index_columns_key] + ')'
                  + CASE 
                      WHEN [index_columns_include] <> '---' 
                      THEN ' INCLUDE (' + [index_columns_include] + ')' 
                      ELSE '' 
                    END
                  + CASE
                      WHEN [has_filter] = 1 
                      THEN ' ' + [filter_definition]
                      ELSE ' '
                    END
                  + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN [fill_factor] <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),[fill_factor]) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
                      
             ELSE ''
           END + ','
  FROM @RESULTS
  WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 1 
    OR  [is_unique] = 1
  ORDER BY 
    [is_primary_key] DESC,
    [is_unique] DESC;
--##############################################################################
--indexes
--##############################################################################
  SELECT @INDEXSQLS = @INDEXSQLS 
         + CASE
             WHEN [is_primary_key] = 0 OR [is_unique] = 0
             THEN @vbCrLf
                  + 'CREATE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [type_desc] + ' INDEX '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' '
                  + @vbCrLf
                  + '   ON '   COLLATE SQL_Latin1_General_CP1_CI_AS
                  + quotename([schema_name]) + '.' + quotename([OBJECT_NAME])
                  + CASE 
                        WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                        THEN ' (' + [index_columns_include] + ')' 
                        ELSE ' (' + [index_columns_key] + ')'
                    END
                  + CASE 
                      WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                      THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE
                        CASE
                     WHEN [index_columns_include] <> '---' 
                     THEN @vbCrLf + '   INCLUDE ('  COLLATE SQL_Latin1_General_CP1_CI_AS + [index_columns_include] + ')'   COLLATE SQL_Latin1_General_CP1_CI_AS
                     ELSE ''   COLLATE SQL_Latin1_General_CP1_CI_AS
                   END
                    END
                  --2008 filtered indexes syntax
                  + CASE 
                      WHEN [has_filter] = 1 
                      THEN @vbCrLf + '   WHERE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [filter_definition]
                      ELSE ''
                    END
                  + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                  THEN ' WITH ('  COLLATE SQL_Latin1_General_CP1_CI_AS + CASE
                                    WHEN [fill_factor] <> 0 
                                    THEN 'FILLFACTOR = '  COLLATE SQL_Latin1_General_CP1_CI_AS + CONVERT(VARCHAR(30),[fill_factor]) 
                                    ELSE '' 
                                  END
                                + CASE
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression]+' '
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression]+' '
                                    ELSE '' 
                                  END
                                  + ')'

                  ELSE '' 
                  END 
           END
  FROM @RESULTS
  WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 0 
    AND [is_unique] = 0
  ORDER BY 
    [is_primary_key] DESC,
    [is_unique] DESC;

  IF @INDEXSQLS <> ''  COLLATE SQL_Latin1_General_CP1_CI_AS
    SET @INDEXSQLS = @vbCrLf + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + @INDEXSQLS;
--##############################################################################
--CHECK Constraints
--##############################################################################
  SET @CHECKCONSTSQLS = ''  COLLATE SQL_Latin1_General_CP1_CI_AS;
  SELECT
    @CHECKCONSTSQLS = @CHECKCONSTSQLS
    + @vbCrLf
    + ISNULL('CONSTRAINT   ' + quotename([OBJS].[name]) + ' '
    + SPACE(@STRINGLEN - LEN([OBJS].[name]))
    + ' CHECK ' + ISNULL([CHECKS].[definition],'')
    + ',','')
  FROM [sys].[objects] [OBJS]
    INNER JOIN [sys].[check_constraints] [CHECKS] ON [OBJS].[object_id] = [CHECKS].[object_id]
  WHERE [OBJS].[type] = 'C'
    AND [OBJS].[parent_object_id] = @TABLE_ID;
--##############################################################################
--FOREIGN KEYS
--##############################################################################
  SET @FKSQLS = '' ;
    SELECT
    @FKSQLS=@FKSQLS
    + @vbCrLf + [MyAlias].[Command] FROM
(
SELECT
  DISTINCT
  --FK must be added AFTER the PK/unique constraints are added back.
  850 AS [ExecutionOrder],
  'CONSTRAINT ' 
  + QUOTENAME([conz].[name]) 
  + ' FOREIGN KEY (' 
  + [ChildCollection].[ChildColumns] 
  + ') REFERENCES ' 
  + QUOTENAME(SCHEMA_NAME([conz].[schema_id])) 
  + '.' 
  + QUOTENAME(OBJECT_NAME([conz].[referenced_object_id])) 
  + ' (' + [ParentCollection].[ParentColumns] 
  + ') ' 

  +  CASE [conz].[update_referential_action]
                                        WHEN 0 THEN '' --' ON UPDATE NO ACTION '
                                        WHEN 1 THEN ' ON UPDATE CASCADE '
                                        WHEN 2 THEN ' ON UPDATE SET NULL '
                                        ELSE ' ON UPDATE SET DEFAULT '
                                    END
                  + CASE [conz].[delete_referential_action]
                                        WHEN 0 THEN '' --' ON DELETE NO ACTION '
                                        WHEN 1 THEN ' ON DELETE CASCADE '
                                        WHEN 2 THEN ' ON DELETE SET NULL '
                                        ELSE ' ON DELETE SET DEFAULT '
                                    END
                  + CASE [conz].[is_not_for_replication]
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
  + ',' AS [Command]
FROM   [sys].[foreign_keys] [conz]
       INNER JOIN [sys].[foreign_key_columns] [colz]
         ON [conz].[object_id] = [colz].[constraint_object_id]
      
       INNER JOIN (--gets my child tables column names   
SELECT
 [conz].[name],
 --technically, FK's can contain up to 16 columns, but real life is often a single column. coding here is for all columns
 [ChildColumns] = STUFF((SELECT 
                         ',' + QUOTENAME([REFZ].[name])
                       FROM   [sys].[foreign_key_columns] [fkcolz]
                              INNER JOIN [sys].[columns] [REFZ]
                                ON [fkcolz].[parent_object_id] = [REFZ].[object_id]
                                   AND [fkcolz].[parent_column_id] = [REFZ].[column_id]
                       WHERE [fkcolz].[parent_object_id] = [conz].[parent_object_id]
                           AND [fkcolz].[constraint_object_id] = [conz].[object_id]
                         ORDER  BY
                        [fkcolz].[constraint_column_id]
                      FOR XML PATH(''), TYPE).[value]('.','varchar(max)'),1,1,'')
FROM   [sys].[foreign_keys] [conz]
      INNER JOIN [sys].[foreign_key_columns] [colz]
        ON [conz].[object_id] = [colz].[constraint_object_id]
        WHERE [conz].[parent_object_id]= @TABLE_ID
GROUP  BY
[conz].[name],
[conz].[parent_object_id],--- without GROUP BY multiple rows are returned
 [conz].[object_id]
    ) [ChildCollection]
         ON [conz].[name] = [ChildCollection].[name]
       INNER JOIN (--gets the parent tables column names for the FK reference
                  SELECT
                     [conz].[name],
                     [ParentColumns] = STUFF((SELECT
                                              ',' + [REFZ].[name]
                                            FROM   [sys].[foreign_key_columns] [fkcolz]
                                                   INNER JOIN [sys].[columns] [REFZ]
                                                     ON [fkcolz].[referenced_object_id] = [REFZ].[object_id]
                                                        AND [fkcolz].[referenced_column_id] = [REFZ].[column_id]
                                            WHERE  [fkcolz].[referenced_object_id] = [conz].[referenced_object_id]
                                              AND [fkcolz].[constraint_object_id] = [conz].[object_id]
                                            ORDER BY [fkcolz].[constraint_column_id]
                                            FOR XML PATH(''), TYPE).[value]('.','varchar(max)'),1,1,'')
                   FROM   [sys].[foreign_keys] [conz]
                          INNER JOIN [sys].[foreign_key_columns] [colz]
                            ON [conz].[object_id] = [colz].[constraint_object_id]
                           -- AND colz.parent_column_id 
                   GROUP  BY
                    [conz].[name],
                    [conz].[referenced_object_id],--- without GROUP BY multiple rows are returned
                    [conz].[object_id]
                  ) [ParentCollection]
         ON [conz].[name] = [ParentCollection].[name]
)[MyAlias];


--##############################################################################
--RULES
--##############################################################################
--  SET @RULESCONSTSQLS = '';
--  SELECT
--    @RULESCONSTSQLS = @RULESCONSTSQLS
--    + ISNULL(
--             @vbCrLf
--             + 'if not exists(SELECT [name] FROM sys.objects WHERE TYPE=''R'' AND schema_id = ' COLLATE SQL_Latin1_General_CP1_CI_AS + CONVERT(VARCHAR(30),[OBJS].[schema_id]) + ' AND [name] = '''  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(OBJECT_NAME([COLS].[rule_object_id])) + ''')'  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf
--             + [MODS].[definition]  + @vbCrLf + 'GO' COLLATE SQL_Latin1_General_CP1_CI_AS +  @vbCrLf
--             + 'EXEC sp_binderule  ' + QUOTENAME([OBJS].[name]) + ', ''' + QUOTENAME(OBJECT_NAME([COLS].[object_id])) + '.' + QUOTENAME([COLS].[name]) + ''''  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS ,'')
--  FROM [sys].[columns] [COLS] 
--    INNER JOIN [sys].[objects] [OBJS]
--      ON [OBJS].[object_id] = [COLS].[object_id]
--    INNER JOIN [sys].[sql_modules] [MODS]
--      ON [COLS].[rule_object_id] = [MODS].[object_id]
--  WHERE [COLS].[rule_object_id] <> 0
--    AND [COLS].[object_id] = @TABLE_ID;
----##############################################################################
----TRIGGERS
----##############################################################################
--  SET @TRIGGERSTATEMENT = '';
--  SELECT
--    @TRIGGERSTATEMENT = @TRIGGERSTATEMENT +  @vbCrLf + [MODS].[definition] + @vbCrLf + 'GO'
--  FROM [sys].[sql_modules] [MODS]
--  WHERE [MODS].[object_id] IN(SELECT
--                         [OBJS].[object_id]
--                       FROM [sys].[objects] [OBJS]
--                       WHERE [OBJS].[type] = 'TR'
--                       AND [OBJS].[parent_object_id] = @TABLE_ID);
--  IF @TRIGGERSTATEMENT <> ''  COLLATE SQL_Latin1_General_CP1_CI_AS
    --SET @TRIGGERSTATEMENT = @vbCrLf + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + @TRIGGERSTATEMENT;
--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
 -- SET @EXTENDEDPROPERTIES = '';
 -- SELECT  @EXTENDEDPROPERTIES =
 --         @EXTENDEDPROPERTIES + @vbCrLf +
 --        'EXEC sys.sp_addextendedproperty
 --         @name = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS + [name] + ''', @value = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS + REPLACE(CONVERT(VARCHAR(MAX),[value]),'''','''''') + ''',
 --         @level0type = N''SCHEMA'', @level0name = '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(@SCHEMANAME) + ',
 --         @level1type = N''TABLE'', @level1name = '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME(@TBLNAME) + ';'
 ----SELECT objtype, objname, name, value
 -- FROM [sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, NULL, NULL);
 -- --OMacoder suggestion for column extended properties http://www.sqlservercentral.com/Forums/FindPost1651606.aspx
 --  ;WITH [obj] AS (
	--SELECT [split].[a].[value]('.', 'VARCHAR(20)') AS [name]
	--FROM ( 
	--	SELECT CAST ('<M>' + REPLACE('column,constraint,index,trigger,parameter', ',', '</M><M>') + '</M>' AS XML) AS [data] 
	--	) AS [A] 
	--	CROSS APPLY [data].[nodes] ('/M') AS [split]([a])
	--)
 -- SELECT 
 -- @EXTENDEDPROPERTIES =
	--	 @EXTENDEDPROPERTIES + @vbCrLf + @vbCrLf +
 --        'EXEC sys.sp_addextendedproperty
 --        @name = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + [lep].[name] 
 --        + ''', @value = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + REPLACE(CONVERT(VARCHAR(MAX),[lep].[value]),'''','''''') + ''',
 --        @level0type = N''SCHEMA'', @level0name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + QUOTENAME(@SCHEMANAME) 
 --        + ',
 --        @level1type = N''TABLE'', @level1name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + QUOTENAME(@TBLNAME) 
 --        + ',
 --        @level2type = N''' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + UPPER([obj].[name])  
 --        + ''', @level2name = ' COLLATE SQL_Latin1_General_CP1_CI_AS
 --        + QUOTENAME([lep].[objname]) + ';' COLLATE SQL_Latin1_General_CP1_CI_AS
 -- --SELECT objtype, objname, name, value
 -- FROM [obj] 
	--CROSS APPLY [sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, [obj].[name], NULL) AS [lep];  
  
 -- IF @EXTENDEDPROPERTIES <> '' COLLATE SQL_Latin1_General_CP1_CI_AS
 --   SET @EXTENDEDPROPERTIES = @vbCrLf + 'GO' COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + @EXTENDEDPROPERTIES;
--##############################################################################
--FINAL CLEANUP AND PRESENTATION
--##############################################################################
--at this point, there is a trailing comma, or it blank
  SELECT
    @FINALSQL = @FINALSQL
                + @CONSTRAINTSQLS
                + @CHECKCONSTSQLS
                + @FKSQLS;
--note that this trims the trailing comma from the end of the statements
  SET @FINALSQL = SUBSTRING(@FINALSQL,1,LEN(@FINALSQL) -1) ;
  SET @FINALSQL = @FINALSQL + ')' COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf ;

  SET @input = @vbCrLf
       + @FINALSQL
       + @INDEXSQLS
       + @RULESCONSTSQLS
       + @TRIGGERSTATEMENT
       + @EXTENDEDPROPERTIES
  --ten years worth of days from todays date:
   ;WITH [E01]([N]) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1), --         10 or 10E01 rows
         [E02]([N]) AS (SELECT 1 FROM [E01] [a], [E01] [b]),  --        100 or 10E02 rows
         [E04]([N]) AS (SELECT 1 FROM [E02] [a], [E02] [b]),  --     10,000 or 10E04 rows
         [E08]([N]) AS (SELECT 1 FROM [E04] [a], [E04] [b]),  --100,000,000 or 10E08 rows
         --E16(N) AS (SELECT 1 FROM E08 a, E08 b),  --10E16 or more rows than you'll EVER need,
         [Tally]([N]) AS (SELECT ROW_NUMBER() OVER (ORDER BY [E08].[N]) FROM [E08]),
       [ItemSplit](
                 [ItemOrder],
                 [Item]
                ) AS (
                      SELECT [Tally].[N],
                        SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf),CHARINDEX(@vbCrLf,@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf)) - [Tally].[N] - DATALENGTH(@vbCrLf))
                      FROM [Tally]
                      WHERE [Tally].[N] < DATALENGTH(@vbCrLf + @input)
                      --WHERE N < DATALENGTH(@vbCrLf + @input) -- REMOVED added @vbCrLf
                        AND SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N],DATALENGTH(@vbCrLf)) = @vbCrLf --Notice how we find the delimiter
                     )
  SELECT @FINALSQL =
    --row_number() over (order by ItemOrder) as ItemID,
    [ItemSplit].[Item]
  FROM [ItemSplit];
  RETURN;     
--##############################################################################
-- END Normal Table Processing
--############################################################################## 
    
--simple, primitive version to get the results of a TEMP table from the TEMP db.  
--##############################################################################
-- NEW Temp Table Logic
--##############################################################################     
TEMPPROCESS:
  SELECT @TABLE_ID = OBJECT_ID('tempdb..' COLLATE SQL_Latin1_General_CP1_CI_AS + @TBLNAME);

--##############################################################################
-- Valid temp Table, Continue Processing
--##############################################################################
SELECT 
  @FINALSQL =  'IF OBJECT_ID(''tempdb.' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ''') IS NOT NULL ' + @vbcrlf
               + 'DROP TABLE ' + QUOTENAME(@SCHEMANAME) + '.' + QUOTENAME(@TBLNAME) + ' ' + @vbcrlf + 'GO' + @vbcrlf
               + 'CREATE TABLE ' + quotename(@SCHEMANAME) + '.' + quotename(@TBLNAME) + ' ( ';
  --removed invalud cide here which potentially selected wrong table--thansk David Grifiths @SSC!
  SELECT
    @STRINGLEN = MAX(LEN([COLS].[name])) + 1
  FROM [tempdb].[sys].[objects] [OBJS]
    INNER JOIN [tempdb].[sys].[columns] [COLS]
      ON  [OBJS].[object_id] = [COLS].[object_id]
      AND [OBJS].[object_id] = @TABLE_ID;
--##############################################################################
--Get the columns, their definitions and defaults.
--##############################################################################
  SELECT
    @FINALSQL = @FINALSQL
    + CASE
        WHEN [COLS].[is_computed] = 1
        THEN @vbCrLf
             + QUOTENAME([COLS].[name])
             + ' '
             + SPACE(@STRINGLEN - LEN([COLS].[name]))
             + 'AS ' + ISNULL([CALC].[definition],'')
              + CASE 
                 WHEN [CALC].[is_persisted] = 1 
                 THEN ' PERSISTED'
                 ELSE ''
               END
        ELSE @vbCrLf
             + QUOTENAME([COLS].[name])
             + ' '
             + SPACE(@STRINGLEN - LEN([COLS].[name]))
             + UPPER(TYPE_NAME([COLS].[user_type_id]))
             + CASE
-- data types with precision and scale  IE DECIMAL(18,3), NUMERIC(10,2)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('decimal','numeric')
               THEN '('
                    + CONVERT(VARCHAR,[COLS].[precision])
                    + ','
                    + CONVERT(VARCHAR,[COLS].[scale])
                    + ') '
                    + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[precision])
                    + ','
                    + CONVERT(VARCHAR,[COLS].[scale])))
                    + SPACE(7)
                    + SPACE(16 - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + CASE
                        WHEN [COLS].[is_identity] = 1
                        THEN ' IDENTITY(1,1)'
                        ELSE ''
                        ----WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 1
                        ----THEN ' IDENTITY('
                        ----       + CONVERT(VARCHAR,ISNULL(IDENT_SEED('tempdb..' + @TBLNAME),1) )
                        ----       + ','
                        ----       + CONVERT(VARCHAR,ISNULL(IDENT_INCR('tempdb..' + @TBLNAME),1) )
                        ----       + ')'
                        ----ELSE ''
                        END
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
-- data types with scale  IE datetime2(7),TIME(7)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('datetime2','datetimeoffset','time')
               THEN CASE 
                      WHEN [COLS].[scale] < 7 THEN
                      '('
                      + CONVERT(VARCHAR,[COLS].[scale])
                      + ') '
                    ELSE 
                      '    '
                    END
                    + SPACE(4)
                    + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + '        '
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END
--data types with no/precision/scale,IE  FLOAT
               WHEN  TYPE_NAME([COLS].[user_type_id]) IN ('float') --,'real')
               THEN
               --addition: if 53, no need to specifically say (53), otherwise display it
                    CASE
                      WHEN [COLS].[precision] = 53
                      THEN SPACE(11 - LEN(CONVERT(VARCHAR,[COLS].[precision])))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,[COLS].[precision])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[precision])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                      END
--ie VARCHAR(40)
--##############################################################################
-- COLLATE STATEMENTS in tempdb!
-- personally i do not like collation statements,
-- but included here to make it easy on those who do
--##############################################################################

               WHEN  TYPE_NAME([COLS].[user_type_id]) IN ('char','varchar','binary','varbinary')
               THEN CASE
                      WHEN  [COLS].[max_length] = -1
                      THEN  '(max)'
                            + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[max_length])))
                            + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                            ----collate to comment out when not desired
                            --+ CASE
                            --    WHEN COLS.collation_name IS NULL
                            --    THEN ''
                            --    ELSE ' COLLATE ' + COLS.collation_name
                            --  END
                            + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN [COLS].[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
                      ELSE '('
                           + CONVERT(VARCHAR,[COLS].[max_length])
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,[COLS].[max_length])))
                           + SPACE(7) + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           ----collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--data type with max_length ( BUT DOUBLED) ie NCHAR(33), NVARCHAR(40)
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('nchar','nvarchar')
               THEN CASE
                      WHEN  [COLS].[max_length] = -1
                      THEN '(max)'
                           + SPACE(5 - LEN(CONVERT(VARCHAR,([COLS].[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           -- --collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN  ' NOT NULL'
                               ELSE '     NULL'
                             END
                      ELSE '('
                           + CONVERT(VARCHAR,([COLS].[max_length] / 2))
                           + ') '
                           + SPACE(6 - LEN(CONVERT(VARCHAR,([COLS].[max_length] / 2))))
                           + SPACE(7)
                           + SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                           -- --collate to comment out when not desired
                           --+ CASE
                           --     WHEN COLS.collation_name IS NULL
                           --     THEN ''
                           --     ELSE ' COLLATE ' + COLS.collation_name
                           --   END
                           + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                           + CASE
                               WHEN [COLS].[is_nullable] = 0
                               THEN ' NOT NULL'
                               ELSE '     NULL'
                             END
                    END
--  other data type 	IE INT, DATETIME, MONEY, CUSTOM DATA TYPE,...
               WHEN TYPE_NAME([COLS].[user_type_id]) IN ('datetime','money','text','image','real')
               THEN SPACE(18 - LEN(TYPE_NAME([COLS].[user_type_id])))
                    + '              '
                    + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                    + CASE
                        WHEN [COLS].[is_nullable] = 0
                        THEN ' NOT NULL'
                        ELSE '     NULL'
                      END

--IE INT
               ELSE SPACE(@ObjectDataTypeLen - LEN(TYPE_NAME([COLS].[user_type_id])))
                            + CASE
                                WHEN [COLS].[is_identity] = 1
                                THEN ' IDENTITY(1,1)'
                                ELSE '              '
                                ----WHEN COLUMNPROPERTY ( @TABLE_ID , COLS.[name] , 'IsIdentity' ) = 1
                                ----THEN ' IDENTITY('
                                ----     + CONVERT(VARCHAR,ISNULL(IDENT_SEED('tempdb..' + @TBLNAME),1) )
                                ----     + ','
                                ----     + CONVERT(VARCHAR,ISNULL(IDENT_INCR('tempdb..' + @TBLNAME),1) )
                                ----     + ')'
                                ----ELSE '              '
                              END
                            + SPACE(2)
                            + CASE  WHEN [COLS].[is_sparse] = 1 THEN ' sparse' ELSE '       ' END
                            + CASE
                                WHEN [COLS].[is_nullable] = 0
                                THEN ' NOT NULL'
                                ELSE '     NULL'
                              END
               END
             + CASE
                 WHEN [COLS].[default_object_id] = 0
                 THEN ''
                 ELSE ' DEFAULT '  + ISNULL([DEF].[definition] ,'')
                 --optional section in case NAMED default cosntraints are needed:
                 --ELSE ' CONSTRAINT [' + DEF.name + '] DEFAULT '+ REPLACE(REPLACE(ISNULL(DEF.[definition] ,''),'((','('),'))',')')
                        --i thought it needed to be handled differently! NOT!
               END  --CASE cdefault



      END --iscomputed
    + ','
    FROM [tempdb].[sys].[columns] [COLS]
      LEFT OUTER JOIN  [tempdb].[sys].[default_constraints]  [DEF]
        ON [COLS].[default_object_id] = [DEF].[object_id]
      LEFT OUTER JOIN [tempdb].[sys].[computed_columns] [CALC]
         ON  [COLS].[object_id] = [CALC].[object_id]
         AND [COLS].[column_id] = [CALC].[column_id]
    WHERE [COLS].[object_id]=@TABLE_ID
    ORDER BY [COLS].[column_id];
--##############################################################################
--used for formatting the rest of the constraints:
--##############################################################################
  SELECT
    @STRINGLEN = MAX(LEN([OBJS].[name])) + 1
  FROM [tempdb].[sys].[objects] [OBJS];
--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
  DECLARE @Results2  TABLE (
                    [SCHEMA_ID]             INT,
                    [SCHEMA_NAME]           VARCHAR(255),
                    [OBJECT_ID]             INT,
                    [OBJECT_NAME]           VARCHAR(255),
                    [index_id]              INT,
                    [index_name]            VARCHAR(255),
                    [ROWS]                  BIGINT,
                    [SizeMB]                DECIMAL(19,3),
                    [IndexDepth]            INT,
                    [TYPE]                  INT,
                    [type_desc]             VARCHAR(30),
                    [fill_factor]           INT,
                    [is_unique]             INT,
                    [is_primary_key]        INT ,
                    [is_unique_constraint]  INT,
                    [index_columns_key]     VARCHAR(MAX),
                    [index_columns_include] VARCHAR(MAX),
                    [has_filter] bit ,
                    [filter_definition] VARCHAR(MAX),
                    [currentFilegroupName]  varchar(128),
                    [CurrentCompression]    varchar(128));
  INSERT INTO @Results2
    SELECT
      [SCH].[schema_id], [SCH].[name] AS [SCHEMA_NAME],
      [OBJS].[object_id], [OBJS].[name] AS [OBJECT_NAME],
      [IDX].[index_id], ISNULL([IDX].[name], '---') AS [index_name],
      [partitions].[ROWS], [partitions].[SizeMB], INDEXPROPERTY([OBJS].[object_id], [IDX].[name], 'IndexDepth') AS [IndexDepth],
      [IDX].[type], [IDX].[type_desc], [IDX].[fill_factor],
      [IDX].[is_unique], [IDX].[is_primary_key], [IDX].[is_unique_constraint],
      ISNULL([Index_Columns].[index_columns_key], '---') AS [index_columns_key],
      ISNULL([Index_Columns].[index_columns_include], '---') AS [index_columns_include],
      [IDX].[has_filter],
      [IDX].[filter_definition],
      [filz].[name],
      ISNULL([p].[data_compression_desc],'')
    FROM [tempdb].[sys].[objects] [OBJS]
      INNER JOIN [tempdb].[sys].[schemas] [SCH] ON [OBJS].[schema_id]=[SCH].[schema_id]
      INNER JOIN [tempdb].[sys].[indexes] [IDX] ON [OBJS].[object_id]=[IDX].[object_id]
      INNER JOIN [sys].[filegroups] [filz] ON [IDX].[data_space_id] = [filz].[data_space_id]
      INNER JOIN [sys].[partitions] [p]     ON  [IDX].[object_id] =  [p].[object_id]  AND [IDX].[index_id] = [p].[index_id]
      INNER JOIN (
                  SELECT
                    [STATS].[object_id], [STATS].[index_id], SUM([STATS].[row_count]) AS [ROWS],
                    CONVERT(NUMERIC(19,3), CONVERT(NUMERIC(19,3), SUM([STATS].[in_row_reserved_page_count]+[STATS].[lob_reserved_page_count]+[STATS].[row_overflow_reserved_page_count]))/CONVERT(NUMERIC(19,3), 128)) AS [SizeMB]
                  FROM [tempdb].[sys].[dm_db_partition_stats] [STATS]
                  GROUP BY [STATS].[object_id], [STATS].[index_id]
                 ) AS [partitions] 
        ON  [IDX].[object_id]=[partitions].[OBJECT_ID] 
        AND [IDX].[index_id]=[partitions].[index_id]
    CROSS APPLY (
                 SELECT
                   LEFT([Index_Columns].[index_columns_key], LEN([Index_Columns].[index_columns_key])-1) AS [index_columns_key],
                  LEFT([Index_Columns].[index_columns_include], LEN([Index_Columns].[index_columns_include])-1) AS [index_columns_include]
                 FROM
                      (
                       SELECT
                              (
                              SELECT QUOTENAME([COLS].[name]) + CASE WHEN [IXCOLS].[is_descending_key] = 0 THEN ' asc' ELSE ' desc' END + ',' + ' '
                               FROM [tempdb].[sys].[index_columns] [IXCOLS]
                                 INNER JOIN [tempdb].[sys].[columns] [COLS]
                                   ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                   AND [IXCOLS].[object_id] = [COLS].[object_id]
                               WHERE [IXCOLS].[is_included_column] = 0
                                 AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                 AND [IDX].[index_id] = [IXCOLS].[index_id]
                               ORDER BY [IXCOLS].[key_ordinal]
                               FOR XML PATH('')
                              ) AS [index_columns_key],
                             (
                             SELECT QUOTENAME([COLS].[name]) + ',' + ' '
                              FROM [tempdb].[sys].[index_columns] [IXCOLS]
                                INNER JOIN [tempdb].[sys].[columns] [COLS]
                                  ON  [IXCOLS].[column_id]   = [COLS].[column_id]
                                  AND [IXCOLS].[object_id] = [COLS].[object_id]
                              WHERE [IXCOLS].[is_included_column] = 1
                                AND [IDX].[object_id] = [IXCOLS].[object_id] 
                                AND [IDX].[index_id] = [IXCOLS].[index_id]
                              ORDER BY [IXCOLS].[index_column_id]
                              FOR XML PATH('')
                             ) AS [index_columns_include]
                      ) AS [Index_Columns]
                ) AS [Index_Columns]
    WHERE [SCH].[name]  LIKE CASE 
                                     WHEN @SCHEMANAME = '' COLLATE SQL_Latin1_General_CP1_CI_AS
                                     THEN [SCH].[name] 
                                     ELSE @SCHEMANAME 
                                   END
    AND [OBJS].[name] LIKE CASE 
                                  WHEN @TBLNAME = ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  THEN [OBJS].[name] 
                                  ELSE @TBLNAME 
                                END
    ORDER BY 
      [SCH].[name], 
      [OBJS].[name], 
      [IDX].[name];
--@Results2 table has both PK,s Uniques and indexes in thme...pull them out for adding to funal results:
  SET @CONSTRAINTSQLS = '' COLLATE SQL_Latin1_General_CP1_CI_AS;
  SET @INDEXSQLS      = '' COLLATE SQL_Latin1_General_CP1_CI_AS;

--##############################################################################
--constriants
--##############################################################################
  SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS 
         + CASE
             WHEN [is_primary_key] = 1 OR [is_unique] = 1
             THEN @vbCrLf
                  + 'CONSTRAINT   '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' '
                  + SPACE(@STRINGLEN - LEN([index_name]))
                  + CASE  
                      WHEN [is_primary_key] = 1 
                      THEN ' PRIMARY KEY '  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE CASE  
                             WHEN [is_unique] = 1     
                             THEN ' UNIQUE      '     COLLATE SQL_Latin1_General_CP1_CI_AS  
                             ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                           END 
                    END
                  + [type_desc] 
                  + CASE 
                      WHEN [type_desc]='NONCLUSTERED' 
                      THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE '   ' 
                    END
                  + ' (' + [index_columns_key] + ')'
                  + CASE 
                      WHEN [index_columns_include] <> '---' 
                      THEN ' INCLUDE (' + [index_columns_include] + ')' 
                      ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                    END
                  + CASE
                      WHEN [has_filter] = 1 
                      THEN ' ' + [filter_definition]
                      ELSE ' '
                    END
                  + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'
                  THEN ' WITH (' + CASE
                                    WHEN [fill_factor] <> 0 
                                    THEN 'FILLFACTOR = ' + CONVERT(VARCHAR(30),[fill_factor]) 
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                + CASE
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE' THEN ',DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE' THEN ''
                                    WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE' THEN 'DATA_COMPRESSION = ' + [CurrentCompression] + ' '
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                  + ')'

                  ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                  END 
             ELSE '' COLLATE SQL_Latin1_General_CP1_CI_AS
           END + ','
  FROM @Results2
  WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 1 
    OR  [is_unique] = 1
  ORDER BY 
    [is_primary_key] DESC,
    [is_unique] DESC;
--##############################################################################
--indexes
--##############################################################################
  SELECT @INDEXSQLS = @INDEXSQLS 
         + CASE
             WHEN [is_primary_key] = 0 OR [is_unique] = 0
             THEN @vbCrLf
                  + 'CREATE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [type_desc] + ' INDEX '  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([index_name]) + ' ' COLLATE SQL_Latin1_General_CP1_CI_AS
                  + @vbCrLf
                  + '   ON '  COLLATE SQL_Latin1_General_CP1_CI_AS
                  + quotename([schema_name]) + '.' + quotename([OBJECT_NAME])
                  + CASE 
                        WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                        THEN ' ('  COLLATE SQL_Latin1_General_CP1_CI_AS+ [index_columns_include] + ')'  COLLATE SQL_Latin1_General_CP1_CI_AS
                        ELSE ' ('  COLLATE SQL_Latin1_General_CP1_CI_AS+ [index_columns_key] + ')' COLLATE SQL_Latin1_General_CP1_CI_AS
                    END
                  + CASE 
                      WHEN [CurrentCompression] = 'COLUMNSTORE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                      THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                      ELSE
                        CASE
                     WHEN [index_columns_include] <> '---' 
                     THEN @vbCrLf + '   INCLUDE ('  COLLATE SQL_Latin1_General_CP1_CI_AS + [index_columns_include] + ')'  COLLATE SQL_Latin1_General_CP1_CI_AS 
                     ELSE ''   COLLATE SQL_Latin1_General_CP1_CI_AS
                   END
                    END
                  --2008 filtered indexes syntax
                  + CASE 
                      WHEN [has_filter] = 1 
                      THEN @vbCrLf + '   WHERE '  COLLATE SQL_Latin1_General_CP1_CI_AS + [filter_definition]
                      ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                    END
                  + CASE WHEN [fill_factor] <> 0 OR [CurrentCompression] <> 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS
                  THEN ' WITH ('  COLLATE SQL_Latin1_General_CP1_CI_AS + CASE
                                    WHEN [fill_factor] <> 0 
                                    THEN 'FILLFACTOR = '  COLLATE SQL_Latin1_General_CP1_CI_AS + CONVERT(VARCHAR(30),[fill_factor]) 
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                + CASE
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression] <> 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS THEN ',DATA_COMPRESSION = ' COLLATE SQL_Latin1_General_CP1_CI_AS + [CurrentCompression] + ' '
                                    WHEN [fill_factor] <> 0  AND [CurrentCompression]  = 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS THEN ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                    WHEN [fill_factor]  = 0  AND [CurrentCompression] <> 'NONE'  COLLATE SQL_Latin1_General_CP1_CI_AS THEN 'DATA_COMPRESSION = '  COLLATE SQL_Latin1_General_CP1_CI_AS+ [CurrentCompression] + ' '
                                    ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                                  END
                                  + ')' COLLATE SQL_Latin1_General_CP1_CI_AS

                  ELSE ''  COLLATE SQL_Latin1_General_CP1_CI_AS
                  END 
           END
  FROM @Results2
  WHERE [type_desc] != 'HEAP'
    AND [is_primary_key] = 0 
    AND [is_unique] = 0
  ORDER BY 
    [is_primary_key] DESC,
    [is_unique] DESC;

  IF @INDEXSQLS <> '' COLLATE SQL_Latin1_General_CP1_CI_AS
    SET @INDEXSQLS = @vbCrLf + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS+ @vbCrLf + @INDEXSQLS;
--##############################################################################
--CHECK Constraints
--##############################################################################
  SET @CHECKCONSTSQLS = '';
  SELECT
    @CHECKCONSTSQLS = @CHECKCONSTSQLS
    + @vbCrLf
    + ISNULL('CONSTRAINT   ' + quotename([OBJS].[name]) + ' '
    + SPACE(@STRINGLEN - LEN([OBJS].[name]))
    + ' CHECK ' + ISNULL([CHECKS].[definition],'')
    + ',','')
  FROM [tempdb].[sys].[objects] [OBJS]
    INNER JOIN [tempdb].[sys].[check_constraints] [CHECKS] ON [OBJS].[object_id] = [CHECKS].[object_id]
  WHERE [OBJS].[type] = 'C'
    AND [OBJS].[parent_object_id] = @TABLE_ID;
--##############################################################################
--FOREIGN KEYS
--##############################################################################
  SET @FKSQLS = '' ;
    SELECT
    @FKSQLS=@FKSQLS
    + @vbCrLf + [MyAlias].[Command] FROM
(
SELECT
  DISTINCT
  --FK must be added AFTER the PK/unique constraints are added back.
  850 AS [ExecutionOrder],
  'CONSTRAINT ' 
  + QUOTENAME([conz].[name]) 
  + ' FOREIGN KEY (' 
  + [ChildCollection].[ChildColumns] 
  + ') REFERENCES ' 
  + QUOTENAME(SCHEMA_NAME([conz].[schema_id])) 
  + '.' 
  + QUOTENAME(OBJECT_NAME([conz].[referenced_object_id])) 
  + ' (' + [ParentCollection].[ParentColumns] 
  + ') ' 
   +  CASE [conz].[update_referential_action]
                                        WHEN 0 THEN '' --' ON UPDATE NO ACTION '
                                        WHEN 1 THEN ' ON UPDATE CASCADE '
                                        WHEN 2 THEN ' ON UPDATE SET NULL '
                                        ELSE ' ON UPDATE SET DEFAULT '
                                    END
                  + CASE [conz].[delete_referential_action]
                                        WHEN 0 THEN '' --' ON DELETE NO ACTION '
                                        WHEN 1 THEN ' ON DELETE CASCADE '
                                        WHEN 2 THEN ' ON DELETE SET NULL '
                                        ELSE ' ON DELETE SET DEFAULT '
                                    END
                  + CASE [conz].[is_not_for_replication]
                        WHEN 1 THEN ' NOT FOR REPLICATION '
                        ELSE ''
                    END
  + ',' AS [Command]
FROM   [sys].[foreign_keys] [conz]
       INNER JOIN [sys].[foreign_key_columns] [colz]
         ON [conz].[object_id] = [colz].[constraint_object_id]
      
       INNER JOIN (--gets my child tables column names   
SELECT
 [conz].[name],
 --technically, FK's can contain up to 16 columns, but real life is often a single column. coding here is for all columns
 [ChildColumns] = STUFF((SELECT 
                         ',' + QUOTENAME([REFZ].[name])
                       FROM   [sys].[foreign_key_columns] [fkcolz]
                              INNER JOIN [sys].[columns] [REFZ]
                                ON [fkcolz].[parent_object_id] = [REFZ].[object_id]
                                   AND [fkcolz].[parent_column_id] = [REFZ].[column_id]
                       WHERE [fkcolz].[parent_object_id] = [conz].[parent_object_id]
                           AND [fkcolz].[constraint_object_id] = [conz].[object_id]
                         ORDER  BY
                        [fkcolz].[constraint_column_id]
                       FOR XML PATH(''), TYPE).[value]('.','varchar(max)'),1,1,'')
FROM   [sys].[foreign_keys] [conz]
      INNER JOIN [sys].[foreign_key_columns] [colz]
        ON [conz].[object_id] = [colz].[constraint_object_id]
 WHERE [conz].[parent_object_id]= @TABLE_ID
GROUP  BY
[conz].[name],
[conz].[parent_object_id],--- without GROUP BY multiple rows are returned
 [conz].[object_id]
    ) [ChildCollection]
         ON [conz].[name] = [ChildCollection].[name]
       INNER JOIN (--gets the parent tables column names for the FK reference
                  SELECT
                     [conz].[name],
                     [ParentColumns] = STUFF((SELECT
                                              ',' + [REFZ].[name]
                                            FROM   [sys].[foreign_key_columns] [fkcolz]
                                                   INNER JOIN [sys].[columns] [REFZ]
                                                     ON [fkcolz].[referenced_object_id] = [REFZ].[object_id]
                                                        AND [fkcolz].[referenced_column_id] = [REFZ].[column_id]
                                            WHERE  [fkcolz].[referenced_object_id] = [conz].[referenced_object_id]
                                              AND [fkcolz].[constraint_object_id] = [conz].[object_id]
                                            ORDER BY [fkcolz].[constraint_column_id]
                                            FOR XML PATH(''), TYPE).[value]('.','varchar(max)'),1,1,'')
                   FROM   [sys].[foreign_keys] [conz]
                          INNER JOIN [sys].[foreign_key_columns] [colz]
                            ON [conz].[object_id] = [colz].[constraint_object_id]
                           -- AND colz.parent_column_id 
                   GROUP  BY
                    [conz].[name],
                    [conz].[referenced_object_id],--- without GROUP BY multiple rows are returned
                    [conz].[object_id]
                  ) [ParentCollection]
         ON [conz].[name] = [ParentCollection].[name]
)[MyAlias];

----##############################################################################
----RULES
----##############################################################################
--  SET @RULESCONSTSQLS = ''  COLLATE SQL_Latin1_General_CP1_CI_AS;
--  SELECT
--    @RULESCONSTSQLS = @RULESCONSTSQLS
--    + ISNULL(
--             @vbCrLf
--             + 'if not exists(SELECT [name] FROM tempdb.sys.objects WHERE TYPE=''R'' AND schema_id = '  COLLATE SQL_Latin1_General_CP1_CI_AS 
--             + CONVERT(VARCHAR(30),[OBJS].[schema_id]) 
--             + ' AND [name] = '''  COLLATE SQL_Latin1_General_CP1_CI_AS
--             + QUOTENAME(OBJECT_NAME([COLS].[rule_object_id])) 
--             + ''')'  COLLATE SQL_Latin1_General_CP1_CI_AS
--             + @vbCrLf
--             + [MODS].[definition]  + @vbCrLf 
--             + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS +  @vbCrLf
--             + 'EXEC sp_binderule  '  COLLATE SQL_Latin1_General_CP1_CI_AS
--             + QUOTENAME([OBJS].[name]) 
--             + ', '''  COLLATE SQL_Latin1_General_CP1_CI_AS 
--             + QUOTENAME(OBJECT_NAME([COLS].[object_id])) 
--             + '.'  COLLATE SQL_Latin1_General_CP1_CI_AS + QUOTENAME([COLS].[name]) 
--             + ''''  COLLATE SQL_Latin1_General_CP1_CI_AS
--             + @vbCrLf 
--             + 'GO' ,''  COLLATE SQL_Latin1_General_CP1_CI_AS)
--  FROM [tempdb].[sys].[columns] [COLS] 
--    INNER JOIN [tempdb].[sys].[objects] [OBJS]
--      ON [OBJS].[object_id] = [COLS].[object_id]
--    INNER JOIN [tempdb].[sys].[sql_modules] [MODS]
--      ON [COLS].[rule_object_id] = [MODS].[object_id]
--  WHERE [COLS].[rule_object_id] <> 0
--    AND [COLS].[object_id] = @TABLE_ID;
----##############################################################################
----TRIGGERS
----##############################################################################
--  SET @TRIGGERSTATEMENT = '';
--  SELECT
--    @TRIGGERSTATEMENT = @TRIGGERSTATEMENT +  @vbCrLf + [MODS].[definition] + @vbCrLf + 'GO'
--  FROM [tempdb].[sys].[sql_modules] [MODS]
--  WHERE [MODS].[object_id] IN(SELECT
--                         [OBJS].[object_id]
--                       FROM [tempdb].[sys].[objects] [OBJS]
--                       WHERE [OBJS].[type] = 'TR'
--                       AND [OBJS].[parent_object_id] = @TABLE_ID);
--  IF @TRIGGERSTATEMENT <> ''  COLLATE SQL_Latin1_General_CP1_CI_AS
--    SET @TRIGGERSTATEMENT = @vbCrLf + 'GO'  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + @TRIGGERSTATEMENT;
--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
  SET @EXTENDEDPROPERTIES = ''  COLLATE SQL_Latin1_General_CP1_CI_AS;
  SELECT  @EXTENDEDPROPERTIES =
          @EXTENDEDPROPERTIES + @vbCrLf +
         'EXEC tempdb.sys.sp_addextendedproperty
          @name = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS
          + [name] 
          + ''', @value = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS
          + REPLACE(CONVERT(VARCHAR(MAX),[value]),'''','''''') + ''',
          @level0type = N''SCHEMA'', @level0name = '  COLLATE SQL_Latin1_General_CP1_CI_AS
          + QUOTENAME(@SCHEMANAME + ',
          @level1type = N''TABLE'', @level1name = ['  COLLATE SQL_Latin1_General_CP1_CI_AS
          + @TBLNAME) 
          + '];' COLLATE SQL_Latin1_General_CP1_CI_AS
 --SELECT objtype, objname, name, value
  FROM [sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, NULL, NULL);
  --OMacoder suggestion for column extended properties http://www.sqlservercentral.com/Forums/FindPost1651606.aspx
  SELECT @EXTENDEDPROPERTIES =
         @EXTENDEDPROPERTIES + @vbCrLf +
         'EXEC sys.sp_addextendedproperty
         @name = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS
         + [name] 
         + ''', @value = N'''  COLLATE SQL_Latin1_General_CP1_CI_AS
         + REPLACE(CONVERT(VARCHAR(MAX),[value]),'''','''''') 
         + ''',
         @level0type = N''SCHEMA'', @level0name = '  COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME(@SCHEMANAME) + ',
         @level1type = N''TABLE'', @level1name = '  COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME(@TBLNAME) + ',
         @level2type = N''COLUMN'', @level2name = '  COLLATE SQL_Latin1_General_CP1_CI_AS
         + QUOTENAME([objname]) + ';' COLLATE SQL_Latin1_General_CP1_CI_AS
  --SELECT objtype, objname, name, value
  FROM [sys].[fn_listextendedproperty] (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, 'column', NULL);
  IF @EXTENDEDPROPERTIES <> '' COLLATE SQL_Latin1_General_CP1_CI_AS
    SET @EXTENDEDPROPERTIES = @vbCrLf + 'GO' COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf + @EXTENDEDPROPERTIES;

--##############################################################################
--FINAL CLEANUP AND PRESENTATION
--##############################################################################
--at this point, there is a trailing comma, or it blank
  SELECT
    @FINALSQL = @FINALSQL
                + @CONSTRAINTSQLS
                + @CHECKCONSTSQLS
                + @FKSQLS;

--note that this trims the trailing comma from the end of the statements
  SET @FINALSQL = SUBSTRING(@FINALSQL,1,LEN(@FINALSQL) -1) ;
  SET @FINALSQL = @FINALSQL + ')'  COLLATE SQL_Latin1_General_CP1_CI_AS + @vbCrLf ;

  SET @input = @vbCrLf
       + @FINALSQL
       + @INDEXSQLS
       + @RULESCONSTSQLS
       + @TRIGGERSTATEMENT
       + @EXTENDEDPROPERTIES
--ten years worth of days from todays date:
   ;WITH [E01]([N]) AS (SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1 UNION ALL
                    SELECT 1 UNION ALL SELECT 1), --         10 or 10E01 rows
         [E02]([N]) AS (SELECT 1 FROM [E01] [a], [E01] [b]),  --        100 or 10E02 rows
         [E04]([N]) AS (SELECT 1 FROM [E02] [a], [E02] [b]),  --     10,000 or 10E04 rows
         [E08]([N]) AS (SELECT 1 FROM [E04] [a], [E04] [b]),  --100,000,000 or 10E08 rows
         --E16(N) AS (SELECT 1 FROM E08 a, E08 b),  --10E16 or more rows than you'll EVER need,
         [Tally]([N]) AS (SELECT ROW_NUMBER() OVER (ORDER BY [E08].[N]) FROM [E08]),
       [ItemSplit](
                 [ItemOrder],
                 [Item]
                ) AS (
                      SELECT [Tally].[N],
                        SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf),CHARINDEX(@vbCrLf,@vbCrLf + @input + @vbCrLf,[Tally].[N] + DATALENGTH(@vbCrLf)) - [Tally].[N] - DATALENGTH(@vbCrLf))
                      FROM [Tally]
                      WHERE [Tally].[N] < DATALENGTH(@vbCrLf + @input)
                      --WHERE N < DATALENGTH(@vbCrLf + @input) -- REMOVED added @vbCrLf
                        AND SUBSTRING(@vbCrLf + @input + @vbCrLf,[Tally].[N],DATALENGTH(@vbCrLf)) = @vbCrLf --Notice how we find the delimiter
                     )
  SELECT @FINALSQL =
    --row_number() over (order by ItemOrder) as ItemID,
    [ItemSplit].[Item]
  FROM [ItemSplit];
         
  RETURN;     
         RETURN 0;
END; --PROC

GO
