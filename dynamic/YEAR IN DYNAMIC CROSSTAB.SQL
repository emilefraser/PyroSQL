Forming Year column header in dynamic crosstab query:
-- SQL pivot crosstab report - SQL QUOTENAME - SQL dynamic pivot
-- SQL dynamic crosstab report with pivot - SQL dynamic sql
USE AdventureWorks
GO
DECLARE  @OrderYear  AS  TABLE(
                               YYYY INT    NOT NULL    PRIMARY KEY
                               )
DECLARE  @SQLtext  AS NVARCHAR(4000)
 
INSERT INTO @OrderYear
SELECT DISTINCT Year(OrderDate)
FROM   Sales.SalesOrderHeader
 
DECLARE  @ReportColumnNames  AS NVARCHAR(MAX),
         @IterationYear      AS INT
 
SET @IterationYear = (SELECT Min(YYYY)
                      FROM   @OrderYear)
 
SET @ReportColumnNames = N''
 
-- Assemble pivot list dynamically
WHILE (@IterationYear IS NOT NULL)
  BEGIN
    SET @ReportColumnNames = @ReportColumnNames + N', ' +
         QUOTENAME(Cast(@IterationYear AS NVARCHAR(10)))
    
    SET @IterationYear = (SELECT Min(YYYY)
                          FROM   @OrderYear
                          WHERE  YYYY > @IterationYear)
  END
 
SET @ReportColumnNames = Substring(@ReportColumnNames,2,Len(@ReportColumnNames))
 
SET @SQLtext = N'SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name, 
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight))
  FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s 
ON soh.CustomerID = s.CustomerID) as Header 
PIVOT (SUM(Freight) FOR OrderYear IN(' + @ReportColumnNames + N')) 
AS Pvt ORDER BY 1'
 
PRINT @SQLtext -- Testing & debugging
-- SQL QUOTENAME placed the square brackets around the year (YYYY)
 
/*
SELECT * FROM (SELECT [Store (Freight Summary)]=s.Name, 
YEAR(OrderDate) AS OrderYear,  Freight = convert(money,convert(varchar, Freight)) 
FROM Sales.SalesOrderHeader soh  JOIN Sales.Store s 
ON soh.CustomerID = s.CustomerID) as Header 
PIVOT (SUM(Freight) FOR OrderYear IN([2001],[2002],[2003],[2004])) 
AS Pvt ORDER BY 1
*/
 
— Execute dynamic sql query
EXEC Sp_executesql   @SQLtext
GO
/* Partial results
 
Store (Freight Summary)             2001        2002        2003        2004
Grease and Oil Products Company     104.02      555.02      726.75     272.28
Great Bicycle Supply                4430.26     3871.35     NULL        NULL
Great Bikes                         1653.89     7445.16     7525.98    584.63
Greater Bike Store                  489.79      1454.78     864.08     245.22
*/