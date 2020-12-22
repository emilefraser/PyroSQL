;WITH   cte ( [ID] ,IDSchema,Nome,Tipo,level, SortCol)
AS     (SELECT [so].[object_id] AS ID
               ,so.[schema_id],so.[name],so.[type]
               ,0 AS [Level]     
               ,CAST ([so].[object_id] AS VARBINARY (MAX)) AS SortCol
          FROM [sys].[objects] so
            LEFT JOIN  sys.sql_expression_dependencies ed ON [ed].[referenced_id]=[so].[object_id]
            LEFT JOIN [sys].[objects] rso ON rso.[object_id]=[ed].referencing_id
            --in my database, if i insert tables on the search, it gets more tham 100 levels of recursivity, and that is bad
        WHERE [rso].[type]  IS NULL AND [so].[type] IN ('V','IF','FN','TF','P')

        UNION ALL
        SELECT [so].[object_id] AS ID
            ,so.[schema_id],so.[name],so.[type]
               ,Level + 1
               ,CAST (SortCol + CAST ([so].[object_id] AS BINARY (4)) AS VARBINARY (MAX))
        FROM   [sys].[objects] so
               INNER JOIN  sys.sql_expression_dependencies ed ON [ed].[referenced_id]=[so].[object_id]
               INNER JOIN [sys].[objects] rso ON rso.[object_id]=[ed].referencing_id
               INNER JOIN cte AS cp ON rso.[object_id] = [cp].[ID]
            WHERE [so].[type] IN ('V','IF','FN','TF','P')
            AND  ([rso].[type] IS NULL OR  [rso].[type]  IN ('V','IF','FN','TF','P'))
            )

--CTE
SELECT  ID, IDSchema,
    REPLICATE('   ',level)+nome AS Nome,'['+SCHEMA_NAME(IDSchema)+'].['+nome+']' AS Object,Tipo,Level,SortCol
FROM     cte AS p
ORDER BY  sortcol