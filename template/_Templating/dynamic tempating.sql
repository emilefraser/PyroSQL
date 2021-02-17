SELECT        CONVERT(varchar(max), 'ALTER TABLE ' + QUOTENAME(cs.name) + '.' + QUOTENAME(ptab.name) + CHAR(13) + CHAR(10)) 
            + CONVERT(varchar(max), 'ADD CONSTRAINT ' + QUOTENAME(fk.name) + CHAR(13) + CHAR(10)) 
            + CONVERT(varchar(max), 'FOREIGN KEY (' ) 
            + STUFF(( SELECT     ',' + QUOTENAME(c.name) 
                      FROM       sys.columns                c    
                      INNER JOIN sys.foreign_key_columns    fkc 
                             ON  c.column_id              = fkc.parent_column_id  
                             AND c.object_id              = fkc.parent_object_id
                      WHERE      fkc.constraint_object_id = fk.object_id 
                      ORDER BY   fkc.constraint_column_id 
                      FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '')+ CONVERT(varchar(max), ')' + CHAR(13) + CHAR(10) ) 
           + CONVERT(varchar(max), 'REFERENCES ' + QUOTENAME(rs.name) + '.' + QUOTENAME(rtab.name) + '(') 
           + STUFF(( SELECT     ',' + QUOTENAME(c.name) 
                     FROM       sys.columns                c 
                     INNER JOIN sys.foreign_key_columns    fkc 
                            ON  c.column_id              = fkc.referenced_column_id
                            AND c.object_id              = fkc.referenced_object_id
                     WHERE      fkc.constraint_object_id = fk.object_id 
                     ORDER BY   fkc.constraint_column_id 
                     FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') + CONVERT(varchar(max), ');')            
FROM         sys.foreign_keys           fk 
INNER JOIN   sys.tables                 rtab 
       ON    fk.referenced_object_id =  rtab.object_id 
INNER JOIN   sys.schemas                rs 
       ON    rtab.schema_id          =  rs.schema_id 
INNER JOIN   sys.tables                 ptab 
       ON    fk.parent_object_id     =  ptab.object_id 
INNER JOIN   sys.schemas                cs 
       ON    ptab.schema_id          =  cs.schema_id