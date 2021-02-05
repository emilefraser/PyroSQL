CREATE TABLE #Product(ProductID int, ProductName varchar(64)) 
INSERT #Product
EXEC sp_executeSQL N'SELECT ProductID, Name
                    FROM AdventureWorks2008.Production.Product'
-- (504 row(s) affected)
SELECT * FROM #Product ORDER BY ProductName
GO
DROP TABLE #Product