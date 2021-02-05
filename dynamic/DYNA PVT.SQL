------------
-- SQL Server dynamic PIVOT Query - T-SQL Dynamic Pivot Crosstab - Dynamic Columns
------------
-- Unknown number of columns - Dynamic sql example - t sql dynamic query
USE AdventureWorks;
DECLARE @SQLtext AS NVARCHAR(MAX)
DECLARE @ReportColumnNames AS NVARCHAR(MAX)
-- SQL pivot list generation dynamically -  Dynamic pivot list - pivot dynamic
SELECT @ReportColumnNames = Stuff( (
SELECT ', ' + QUOTENAME(YYYY) AS [text()]
FROM (SELECT DISTINCT YYYY=CAST (Year(OrderDate) as VARCHAR)
      FROM Sales.SalesOrderHeader ) x
ORDER BY YYYY
FOR XML PATH ('')), 1, 1, '') -- SQL xml path for comma-limited list generation
PRINT @ReportColumnNames
-- [2001], [2002], [2003], [2004]
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name,
    YEAR(OrderDate) AS OrderYear,
    Freight = convert(money,convert(varchar, Freight))
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.Store s
    ON soh.CustomerID = s.CustomerID) as Header
    PIVOT (SUM(Freight) FOR OrderYear
    IN(' + @ReportColumnNames + N')) AS Pvt
    ORDER BY 1'
PRINT @SQLtext -- Testing & debugging - displays query prior to execution
-- SQL Server t sql execute dynamic sql
EXEC sp_executesql @SQLtext -- Execute dynamic SQL command
GO
/*  Partial results
Store (Freight Summary)       2001        2002        2003        2004
Neighborhood Store            NULL        2289.75     1120.64     NULL
New and Used Bicycles         1242.99     4594.51     4390.48     1671.98
*/
-- SQL injection dynamic SQL - protect from SQL injection attacks 