DECLARE        @ForeignKeyTemplate varchar(max) = '
ALTER TABLE    _ParentTableName_ 
ADD CONSTRAINT _fkName_ 
FOREIGN KEY  ( _ParentColumns_ ) 
REFERENCES     _ReferencedTableName_ 
             ( _ReferencedColumns_ ) 
';