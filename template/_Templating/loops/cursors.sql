/* Simple Cursor template from www.dynamic-sql-and-biml.com */
SET XACT_ABORT, NOCOUNT ON;
 
DECLARE @SQL varchar(max);
 
DECLARE curSQL CURSOR LOCAL STATIC READ_ONLY
FOR
SELECT 'USE ' + name + ';'
+ char(10)
+ 'SELECT DbName = DB_NAME(), NoTables = count(*) from sys.tables;'
FROM sys.databases;
 
OPEN curSQL;
 
if CURSOR_STATUS('local','curSQL') <= 0
  RAISERROR('Cursor curSQL is either empty or has failed somehow', 16, 1);
FETCH NEXT FROM curSQL INTO @SQL;
 
WHILE @@FETCH_STATUS = 0
BEGIN
 
if @SQL is null RAISERROR('SQL statement is null', 16, 1);
 
  exec(@SQL);
  print @SQL;
 
FETCH NEXT FROM curSQL INTO @SQL;
END;
 
if CURSOR_STATUS('local','curSQL') >= 0 CLOSE curSQL;
if CURSOR_STATUS('local','curSQL') >= -2 DEALLOCATE curSQL;