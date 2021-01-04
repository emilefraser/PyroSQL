

SELECT s.name AS [ReferencingSchemaName],
       oa.name AS [ReferencingObjectName],
       oa.type_desc AS [ReferencingObjectType],
       d.referenced_schema_name AS [ReferencedSchemaName],
       da.name AS [ReferencedObjectName],
       da.type_desc AS [ReferencedObjectType]
FROM sys.sql_expression_dependencies d
    LEFT JOIN sys.all_objects oa
        ON d.referencing_id = oa.object_id
    LEFT JOIN sys.all_objects da
        ON d.referenced_id = da.object_id
    LEFT JOIN sys.schemas s
        ON oa.schema_id = s.schema_id
WHERE s.name IS NOT NULL
      AND s.name <> d.referenced_schema_name
      AND s.name NOT IN ( 'SQLCop', 'tSQLt' );
GO

SELECT obj.name AS FK_NAME,
       referencingschema.name AS [ReferencingSchemaName],
       referencingtable.name AS [ReferencingObjectName],
       referencingcolumn.name AS [ReferencingColumnName],
       referencedschema.name AS [ReferencedSchemaName],
       referencedtable.name AS [ReferencedTableName],
       referencedcolumn.name AS [ReferencedColumnName]
FROM sys.foreign_key_columns fkc
    JOIN sys.objects obj
        ON obj.object_id = fkc.constraint_object_id
    JOIN sys.tables AS referencingtable
        ON referencingtable.object_id = fkc.parent_object_id
    JOIN sys.schemas AS referencingschema
        ON referencingtable.schema_id = referencingschema.schema_id
    JOIN sys.columns AS referencingcolumn
        ON referencingcolumn.column_id = fkc.parent_column_id
           AND referencingcolumn.object_id = referencingtable.object_id
    JOIN sys.tables referencedtable
        ON referencedtable.object_id = fkc.referenced_object_id
    JOIN sys.schemas AS referencedschema
        ON referencedtable.schema_id = referencedschema.schema_id
    JOIN sys.columns referencedcolumn
        ON referencedcolumn.column_id = fkc.referenced_column_id
           AND referencedcolumn.object_id = referencedtable.object_id
WHERE referencingschema.name <> referencedschema.name;