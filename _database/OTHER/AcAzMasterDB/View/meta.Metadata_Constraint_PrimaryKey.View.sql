SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[meta].[Metadata_Constraint_PrimaryKey]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [meta].[Metadata_Constraint_PrimaryKey]
AS
     SELECT SCHEMA_NAME(tab.schema_id) AS [schema_name], 
            pk.[name] AS pk_name, 
            SUBSTRING(column_names, 1, LEN(column_names) - 1) AS [columns], 
            tab.[name] AS table_name
     FROM sys.tables tab
          INNER JOIN sys.indexes pk ON tab.object_id = pk.object_id
                                       AND pk.is_primary_key = 1
          CROSS APPLY
     (
         SELECT col.[name] + '', ''
         FROM sys.index_columns ic
              INNER JOIN sys.columns col ON ic.object_id = col.object_id
                                            AND ic.column_id = col.column_id
         WHERE ic.object_id = tab.object_id
               AND ic.index_id = pk.index_id
         ORDER BY col.column_id FOR XML PATH('''')
     ) D(column_names)
    -- ORDER BY SCHEMA_NAME(tab.schema_id), 
    --          pk.[name];
' 
GO
