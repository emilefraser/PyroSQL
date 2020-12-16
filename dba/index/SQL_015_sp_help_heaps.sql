USE master;

GO

IF OBJECT_ID('[dbo].[sp_help_heaps]') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_help_heaps];

GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_heaps]
AS
SELECT Quotename(Object_schema_name(idx.object_id))
       + '.' 
            + QUOTENAME(OBJECT_NAME(idx.object_id)) AS QualifiedObject ,
            OBJECT_SCHEMA_NAME(idx.object_id) AS SchemaName ,
            OBJECT_NAME(idx.object_id) AS table_name ,
            fn.forwarded_record_count ,
            fn.avg_fragmentation_in_percent ,
            fn.page_count ,
            'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
            + '.' + QUOTENAME(OBJECT_NAME(idx.object_id)) + ' REBUILD;' AS QuickFix ,
            CASE WHEN colz.is_nullable = 1
                 THEN 'ALTER TABLE '
                      + QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id)) + '.'
                      + QUOTENAME(OBJECT_NAME(idx.object_id))
                      + ' ALTER COLUMN ' + QUOTENAME(colz.name) + ' '
                      + UPPER(TYPE_NAME(colz.[user_type_id])) + ' '
                      + CASE
           -- data types with precision and scale  IE DECIMAL(18,3), NUMERIC(10,2)
                             WHEN TYPE_NAME(colz.[user_type_id]) IN (
                                  'decimal', 'numeric' )
                             THEN '(' + CONVERT(VARCHAR, colz.[precision])
                                  + ',' + CONVERT(VARCHAR, colz.[scale])
                                  + ') ' + SPACE(6
                                                 - LEN(CONVERT(VARCHAR, colz.[precision])
                                                       + ','
                                                       + CONVERT(VARCHAR, colz.[scale])))
                                  + SPACE(7) + SPACE(16
                                                     - LEN(TYPE_NAME(colz.[user_type_id])))
                                  + CASE WHEN COLUMNPROPERTY(idx.object_id,
                                                             colz.[name],
                                                             'IsIdentity') = 0
                                         THEN ''
                                         ELSE ' IDENTITY('
                                              + CONVERT(VARCHAR, ISNULL(IDENT_SEED(QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
                                                              + '.'
                                                              + QUOTENAME(OBJECT_NAME(idx.object_id))),
                                                              1)) + ','
                                              + CONVERT(VARCHAR, ISNULL(IDENT_INCR(QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
                                                              + '.'
                                                              + QUOTENAME(OBJECT_NAME(idx.object_id))),
                                                              1)) + ')'
                                    END
           -- data types with scale  IE datetime2(7),TIME(7)
                             WHEN TYPE_NAME(colz.[user_type_id]) IN (
                                  'datetime2', 'datetimeoffset', 'time' )
                             THEN CASE WHEN colz.[scale] < 7
                                       THEN '('
                                            + CONVERT(VARCHAR, colz.[scale])
                                            + ') '
                                       ELSE '    '
                                  END + SPACE(4) + SPACE(16
                                                         - LEN(TYPE_NAME(colz.[user_type_id])))
                                  + '        '
           --data types with no/precision/scale,IE  FLOAT
                             WHEN TYPE_NAME(colz.[user_type_id]) IN ( 'float' ) --,'real')
                                  THEN
           --addition: if 53, no need to specifically say (53), otherwise display it
                                  CASE WHEN colz.[precision] = 53
                                       THEN SPACE(11
                                                  - LEN(CONVERT(VARCHAR, colz.[precision])))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                       ELSE '('
                                            + CONVERT(VARCHAR, colz.[precision])
                                            + ') ' + SPACE(6
                                                           - LEN(CONVERT(VARCHAR, colz.[precision])))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                  END
           --data type with max_length		ie CHAR (44), VARCHAR(40), BINARY(5000),
           --##############################################################################
           -- COLLATE STATEMENTS
           -- personally i do not like collation statements,
           -- but included here to make it easy on those who do
           --##############################################################################
                             WHEN TYPE_NAME(colz.[user_type_id]) IN ( 'char',
                                                              'varchar',
                                                              'binary',
                                                              'varbinary' )
                             THEN CASE WHEN colz.[max_length] = -1
                                       THEN '(max)' + SPACE(6
                                                            - LEN(CONVERT(VARCHAR, colz.[max_length])))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                       ELSE '('
                                            + CONVERT(VARCHAR, colz.[max_length])
                                            + ') ' + SPACE(6
                                                           - LEN(CONVERT(VARCHAR, colz.[max_length])))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                  END
           --data type with max_length ( BUT DOUBLED) ie NCHAR(33), NVARCHAR(40)
                             WHEN TYPE_NAME(colz.[user_type_id]) IN ( 'nchar',
                                                              'nvarchar' )
                             THEN CASE WHEN colz.[max_length] = -1
                                       THEN '(max)' + SPACE(5
                                                            - LEN(CONVERT(VARCHAR, ( colz.[max_length]
                                                              / 2 ))))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                       ELSE '('
                                            + CONVERT(VARCHAR, ( colz.[max_length]
                                                              / 2 )) + ') '
                                            + SPACE(6
                                                    - LEN(CONVERT(VARCHAR, ( colz.[max_length]
                                                              / 2 ))))
                                            + SPACE(7) + SPACE(16
                                                              - LEN(TYPE_NAME(colz.[user_type_id])))
                                  END
                             WHEN TYPE_NAME(colz.[user_type_id]) IN (
                                  'datetime', 'money', 'text', 'image', 'real' )
                             THEN SPACE(18 - LEN(TYPE_NAME(colz.[user_type_id])))
           --  other data type 	IE INT, DATETIME, MONEY, CUSTOM DATA TYPE,...
                             ELSE SPACE(16 - LEN(TYPE_NAME(colz.[user_type_id])))
                                  + CASE WHEN COLUMNPROPERTY(idx.object_id,
                                                             colz.[name],
                                                             'IsIdentity') = 0
                                         THEN '              '
                                         ELSE ' IDENTITY('
                                              + CONVERT(VARCHAR, ISNULL(IDENT_SEED(QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
                                                              + '.'
                                                              + QUOTENAME(OBJECT_NAME(idx.object_id))),
                                                              1)) + ','
                                              + CONVERT(VARCHAR, ISNULL(IDENT_INCR(QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id))
                                                              + '.'
                                                              + QUOTENAME(OBJECT_NAME(idx.object_id))),
                                                              1)) + ')'
                                    END + SPACE(2)
                        END
                 ELSE ''
            END + '' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13)
            + CHAR(10) + 'ALTER TABLE '
            + QUOTENAME(OBJECT_SCHEMA_NAME(idx.object_id)) + '.'
            + QUOTENAME(OBJECT_NAME(idx.object_id)) + ' ADD CONSTRAINT PK_'
            + REPLACE(REPLACE(REPLACE(OBJECT_NAME(idx.object_id), '_', ''),
                              ' ', ''), '-', '') + '_'
            + REPLACE(REPLACE(REPLACE(colz.name, '_', ''), ' ', ''), '-', '')
            + ' PRIMARY KEY CLUSTERED (' + QUOTENAME(ISNULL(colz.name,
                                                            'column_1'))
            + ');' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10) AS CreatePK
    FROM    sys.indexes idx
            LEFT JOIN sys.columns colz ON idx.object_id = colz.object_id
                                          AND column_id = 1
            CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), idx.object_id,
                                                       DEFAULT, DEFAULT,
                                                       'SAMPLED') fn
    WHERE   idx.index_id = 0
    ORDER BY fn.forwarded_record_count DESC;

GO

--#################################################################################################
--Mark as a system object
EXECUTE sp_MS_marksystemobject '[dbo].[sp_help_heaps]';
--#################################################################################################
