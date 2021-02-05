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