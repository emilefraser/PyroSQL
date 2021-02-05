-- change database context dynamically (USE database substitution)
DECLARE @SQL nvarchar(max), @dbName sysname;
DECLARE DBcursor CURSOR FOR
SELECT name FROM master.dbo.sysdatabases
WHERE name NOT IN ('master','tempdb','model','msdb')
    AND DATABASEPROPERTYEX(name,'status')='ONLINE' ORDER BY name;
OPEN DBcursor; FETCH DBcursor INTO @dbName;
WHILE (@@FETCH_STATUS = 0) -- loop through all db-s
    BEGIN
        DECLARE @dbContext nvarchar(256)=@dbName+'.dbo.'+'sp_executeSQL'
        SET @SQL = 'SELECT ''Database: '+ @dbName +
                    ' table count'' = COUNT(*) FROM sys.tables';
        PRINT @SQL;
-- SELECT 'Database: AdventureWorks table count' = COUNT(*) FROM sys.tables
        EXEC @dbContext @SQL;
        FETCH DBcursor INTO @dbName;
    END; -- while
CLOSE DBcursor; DEALLOCATE DBcursor;
----------