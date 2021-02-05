--------- 
-- SQL Server dynamic sql stored procedure -- parametrized SQL statement
--------- 
CREATE PROCEDURE uspProductSearch @ProductName VARCHAR(32)  = NULL
AS
  BEGIN
    DECLARE  @SQL NVARCHAR(MAX)
    SELECT @SQL = ' SELECT ProductID, ProductName=Name, Color, ListPrice ' + CHAR(10)+
                  ' FROM AdventureWorks2008.Production.Product' + CHAR(10)+
                  ' WHERE 1 = 1 ' + CHAR(10)
    IF @ProductName IS NOT NULL
      SELECT @SQL = @SQL + ' AND Name LIKE @pProductName'
    PRINT @SQL 
-- parametrized execution
    EXEC sp_executesql @SQL, N'@pProductName varchar(32)', @ProductName 
  END
GO
-- Execute dynamic SQL stored procedure with parameter
EXEC uspProductSearch '%bike%' 
/*    ProductID   ProductName             Color ListPrice
....
      710         Mountain Bike Socks, L  White 9.50
      709         Mountain Bike Socks, M  White 9.50  .... */
 
-- Dynamic SQL for OPENQUERY execution within stored procedure
USE AdventureWorks2008;
GO
CREATE PROC sprocGetBOM @ProductID int, @Date date
AS
BEGIN
  DECLARE @SQL nvarchar(max)=
  'SELECT *
   INTO   ##BOM
   FROM   OPENQUERY(localhost,'' EXECUTE
          [AdventureWorks].[dbo].[uspGetBillOfMaterials] '+
                           convert(varchar,@ProductID)+
                           ','''''+convert(varchar,@Date)+''''''')'
  PRINT @SQL
  EXEC sp_executeSQL @SQL
END
GO
EXEC sprocGetBOM 900, '2004-03-15'
GO
SELECT * FROM ##BOM     -- Global temporary table with scope outside the sproc
-- (24 row(s) affected)
DROP TABLE ##BOM

-- Dynamic sorting with specific collation - Dynamic ORDER BY
DECLARE @SQL nvarchar(max)='SELECT ProductID, Name, ListPrice, Color
  FROM AdventureWorks2008.Production.Product
  ORDER BY Name '
DECLARE @Collation nvarchar(max) = 'COLLATE SQL_Latin1_General_CP1250_CS_AS'
SET @SQL=@SQL + @Collation
PRINT @SQL
EXEC sp_executeSQL @SQL          -- Execute dynamic query SQL Server
------------
-- Dynamic (ad-hoc) stored procedure execution with parameter(s)
DECLARE @spName varchar(256) = '[AdventureWorks2008].[dbo].[uspGetManagerEmployees]'
DECLARE @valParm1 int = 1
EXECUTE @spName @valParm1
 
-- Count tables in all databases without looping through db metadata
SET NOCOUNT ON; CREATE TABLE #DBTables ( DBName  SYSNAME, TableCount INT );
DECLARE @DynamicSQL NVARCHAR(MAX) = '';
SELECT @DynamicSQL = @DynamicSQL + 'USE' + QUOTENAME(name)+'; '  +
                 ' insert into #DBTables select ' + Quotename(name,'''') +
                 ', count(*) from sys.tables; ' +char(13)
FROM   sys.databases;
PRINT @DynamicSQL;
EXEC sp_executeSQL   @DynamicSQL;
SELECT   * FROM #DBTables ORDER BY TableCount DESC;
GO
DROP TABLE #DBTables;

-- Create database dynamically
USE AdventureWorks2008;
GO
CREATE PROC uspCreateDB @DBName sysname
AS
BEGIN
  DECLARE @SQL nvarchar(255) = 'CREATE DATABASE '+@DBName;
  EXEC sp_executeSQL @SQL;
END
GO
 
EXEC uspCreateDB 'InventoryJUL';