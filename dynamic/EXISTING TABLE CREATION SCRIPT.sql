DECLARE  

      @object_name SYSNAME  

    , @object_id INT  

    , @SQL NVARCHAR(MAX)  

  

SELECT  

      @object_name = '[' + OBJECT_SCHEMA_NAME(o.[object_id]) + '].[' + OBJECT_NAME([object_id]) + ']'  

    , @object_id = [object_id]  

FROM (SELECT [object_id] = OBJECT_ID('dbo.WorkOut', 'U')) o  

  

SELECT @SQL = 'CREATE TABLE ' + @object_name + CHAR(13) + '(' + CHAR(13) + STUFF((  

    SELECT CHAR(13) + '    , [' + c.name + '] ' +   

        CASE WHEN c.is_computed = 1  

            THEN 'AS ' + OBJECT_DEFINITION(c.[object_id], c.column_id)  

            ELSE   

                CASE WHEN c.system_type_id != c.user_type_id   

                    THEN '[' + SCHEMA_NAME(tp.[schema_id]) + '].[' + tp.name + ']'   

                    ELSE '[' + UPPER(tp.name) + ']'   

                END  +   

                CASE   

                    WHEN tp.name IN ('varchar', 'char', 'varbinary', 'binary')  

                        THEN '(' + CASE WHEN c.max_length = -1   

                                        THEN 'MAX'   

                                        ELSE CAST(c.max_length AS VARCHAR(5))   

                                    END + ')'  

                    WHEN tp.name IN ('nvarchar', 'nchar')  

                        THEN '(' + CASE WHEN c.max_length = -1   

                                        THEN 'MAX'   

                                        ELSE CAST(c.max_length / 2 AS VARCHAR(5))   

                                    END + ')'  

                    WHEN tp.name IN ('datetime2', 'time2', 'datetimeoffset')   

                        THEN '(' + CAST(c.scale AS VARCHAR(5)) + ')'  

                    WHEN tp.name = 'decimal'  

                        THEN '(' + CAST(c.[precision] AS VARCHAR(5)) + ',' + CAST(c.scale AS VARCHAR(5)) + ')'  

                    ELSE ''  

                END +  

                CASE WHEN c.collation_name IS NOT NULL AND c.system_type_id = c.user_type_id   

                    THEN ' COLLATE ' + c.collation_name  

                    ELSE ''  

                END +  

                CASE WHEN c.is_nullable = 1   

                    THEN ' NULL'  

                    ELSE ' NOT NULL'  

                END +  

                CASE WHEN c.default_object_id != 0   

                    THEN ' CONSTRAINT [' + OBJECT_NAME(c.default_object_id) + ']' +   

                         ' DEFAULT ' + OBJECT_DEFINITION(c.default_object_id)  

                    ELSE ''  

                END +   

                CASE WHEN cc.[object_id] IS NOT NULL   

                    THEN ' CONSTRAINT [' + cc.name + '] CHECK ' + cc.[definition]  

                    ELSE ''  

                END +  

                CASE WHEN c.is_identity = 1   

                    THEN ' IDENTITY(' + CAST(IDENTITYPROPERTY(c.[object_id], 'SeedValue') AS VARCHAR(5)) + ',' +   

                                    CAST(IDENTITYPROPERTY(c.[object_id], 'IncrementValue') AS VARCHAR(5)) + ')'   

                    ELSE ''   

                END   

        END  

    FROM sys.columns c WITH(NOLOCK)  

    JOIN sys.types tp WITH(NOLOCK) ON c.user_type_id = tp.user_type_id  

    LEFT JOIN sys.check_constraints cc WITH(NOLOCK)   

         ON c.[object_id] = cc.parent_object_id   

        AND cc.parent_column_id = c.column_id  

    WHERE c.[object_id] = @object_id  

    ORDER BY c.column_id  

    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 7, '      ') +   

    ISNULL((SELECT '  

    , CONSTRAINT [' + i.name + '] PRIMARY KEY ' +   

    CASE WHEN i.index_id = 1   

        THEN 'CLUSTERED'   

        ELSE 'NONCLUSTERED'   

    END +' (' + (  

    SELECT STUFF(CAST((  

        SELECT ', [' + COL_NAME(ic.[object_id], ic.column_id) + ']' +  

                CASE WHEN ic.is_descending_key = 1  

                    THEN ' DESC'  

                    ELSE ''  

                END  

        FROM sys.index_columns ic WITH(NOLOCK)  

        WHERE i.[object_id] = ic.[object_id]  

            AND i.index_id = ic.index_id  

        FOR XML PATH(N''), TYPE) AS NVARCHAR(MAX)), 1, 2, '')) + ')'  

    FROM sys.indexes i WITH(NOLOCK)  

    WHERE i.[object_id] = @object_id  

        AND i.is_primary_key = 1), '') + CHAR(13) + ');'  

  

PRINT @SQL  