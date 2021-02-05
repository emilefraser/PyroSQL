-- SQL pivot crosstab report - SQL dynamic pivot - SQL dynamic sql
-- SQL dynamic crosstab report with pivot
USE AdventureWorks
GO
DECLARE  @SQLtext  AS NVARCHAR(MAX)
DECLARE  @ReportColumnNames  AS NVARCHAR(MAX)
-- SQL pivot list generation dynamically - Dynamic pivot list        
SELECT  @ReportColumnNames = Stuff( (
SELECT ', ' + QUOTENAME(YYYY) AS [text()]
FROM   (SELECT DISTINCT YYYY=CAST (Year(OrderDate) as VARCHAR)
FROM Sales.SalesOrderHeader ) x
ORDER BY YYYY
-- SQL xml path for comma-limited list generation
FOR XML PATH ('')), 1, 1, '')
 
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s
ON soh.CustomerID = s.CustomerID) as Header
PIVOT (SUM(Freight) FOR OrderYear IN(' + @ReportColumnNames + N'))
AS Pvt ORDER BY 1'
 
PRINT @SQLtext -- Testing & debugging
/*
SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s
ON soh.CustomerID = s.CustomerID) as Header
PIVOT (SUM(Freight) FOR OrderYear IN([2001],[2002],[2003],[2004]))
AS Pvt ORDER BY 1
*/
-- SQL dynamic query execution
EXEC sp_executesql   @SQLtext
GO
/* Partial results
 
Store (Freight Summary) 2001        2002        2003        2004
Sundry Sporting Goods   1074.02     4609.31     4272.94     1569.04
Sunny Place Bikes       193.95      802.70      1095.83     411.62
Super Sports Store      102.15      743.51      427.80      301.68
Superb Sales and Repair 1063.69     1547.73     37.28       13.23
*/
------------
-- Simple Dynamic SQL Statement Execution - Dynamic SQL Tutorial 
EXEC sp_executeSQL N'SELECT TOP(7) * FROM Northwind.dbo.Orders ORDER BY NEWID()'
------------ Dynamic SQL WHERE clause
DECLARE @Predicate varchar(128) = 'ProductID=800'
EXEC ('SELECT * FROM AdventureWorks2008.Production.Product WHERE '+@Predicate)
------------ Dynamic view name / table name SELECT
DECLARE @SQL nvarchar(max), @View sysname='Northwind.dbo.Invoices'
SELECT @SQL = 'SELECT * FROM ' + @View
EXEC sp_executeSQL @SQL 
------------
-- Dynamic SQL - dynamic table name - dynamic sql SQL Server - sp_executeSQL
DECLARE @SQL nvarchar(max), @Table sysname='AdventureWorks2008.Production.Product'
SELECT @SQL = 'SELECT Rows=count(*) FROM '      -- count rows dynamic SQL statement 
SELECT @SQL = @SQL + @Table                     -- concatenate string variables 
EXEC (@SQL)                     -- Original dynamic SQL execution command
-- 504                          -- SQL execute dynamic SQL result
EXEC sp_executeSQL @SQL         -- Improved transact-SQL dynamic SQL execute
-- 504