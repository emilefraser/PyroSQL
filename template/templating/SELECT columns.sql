--Gathering of meta data
T--he meta data in this approach must be fetched from the same tables as in the ugly sample in the beginning of this post. 
--But now the focus is on the individual parts that needs to go into the SQL template. 
--The meta data is retrieved as separate fields and reusing the placeholders makes it easy read. My preference is to wrap it in a common table expression, this will separate the meta data retrieval from the replacing of the place holders.

with  cteFkeyMetaData
AS (
      select _ParentTableName_              = QUOTENAME(cs.name) + '.' + QUOTENAME(ptab.name)
           , _fkName_                       = QUOTENAME(fk.name)
           , _ParentColumns_                = STUFF(( SELECT     ',' + QUOTENAME(c.name)
                                                      FROM       sys.columns AS c 
                                                      INNER JOIN sys.foreign_key_columns AS fkc 
                                                              ON fkc.parent_column_id = c.column_id
                                                             AND fkc.parent_object_id = c.object_id
                                                      WHERE      fkc.constraint_object_id = fk.object_id
                                                      ORDER BY   fkc.constraint_column_id 
                                                      FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') 
          , _ReferencedTableName_            = QUOTENAME(rs.name) + '.' + QUOTENAME(rtab.name)
          , _ReferencedColumns_              = STUFF(( SELECT ',' + QUOTENAME(c.name)
                                                       FROM       sys.columns AS c 
                                                       INNER JOIN sys.foreign_key_columns AS fkc 
                                                               ON fkc.referenced_column_id = c.column_id
                                                              AND fkc.referenced_object_id = c.object_id
                                                       WHERE      fkc.constraint_object_id = fk.object_id
                                                       ORDER BY   fkc.constraint_column_id 
                                                       FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') 
         , _delete_referential_action_desc_ = fk.delete_referential_action_desc COLLATE SQL_Latin1_General_CP1_CI_AS
         , _update_referential_action_desc_ = fk.update_referential_action_desc COLLATE SQL_Latin1_General_CP1_CI_AS
FROM       sys.foreign_keys fk
INNER JOIN sys.tables rtab
        ON fk.referenced_object_id = rtab.object_id
INNER JOIN sys.schemas rs 
        ON rtab.[schema_id] = rs.schema_id
INNER JOIN sys.tables ptab 
        ON fk.parent_object_id = ptab.object_id
INNER JOIN sys.schemas cs 
        ON ptab.[schema_id] = cs.schema_id
 )
 SELECT ForeignKeyStmt = REPLACE( 
                        REPLACE( 
                        REPLACE( 
                        REPLACE( 
                        REPLACE( 
                                 @ForeignKeyTemplate 
                               , '_ParentTableName_' , _ParentTableName_) 
                               , '_fkName_' , _fkName_) 
                               , '_ParentColumns_' , _ParentColumns_) 
                               , '_ReferencedTableName_' , _ReferencedTableName_) 
                               , '_ReferencedColumns_' , _ReferencedColumns_) 
     , ForeignKeyTemplate = @ForeignKeyTemplate 
     , * 
FROM   cteFkeyMetaData




