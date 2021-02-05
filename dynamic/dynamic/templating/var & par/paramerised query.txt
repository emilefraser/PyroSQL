-- Parameters are NOT ALLOWED everywhere in an SQL statement - hence dynamic SQL
DECLARE @Color varchar(16) = 'Yellow'
SELECT Color=@Color, ProductCount=COUNT(Color)
FROM AdventureWorks2008.Production.Product
WHERE Color = @Color
/*    Color    ProductCount
      Yellow      36              */

-- SQL Server 2012 sp_executeSQL usage with input and output parameters (2008/2005)
DECLARE @SQL NVARCHAR(max), @ParmDefinition NVARCHAR(1024)
DECLARE @ListPrice money = 2000.0, @LastProduct varchar(64)
SET @SQL = N'SELECT @pLastProduct = max(Name)
             FROM AdventureWorks2008.Production.Product
             WHERE ListPrice >= @pListPrice'
SET @ParmDefinition = N'@pListPrice money,
                        @pLastProduct varchar(64) OUTPUT'
EXECUTE sp_executeSQL -- Dynamic T-SQL
    @SQL,
    @ParmDefinition,
    @pListPrice = @ListPrice,
    @pLastProduct=@LastProduct OUTPUT
SELECT [ListPrice >=]=@ListPrice, LastProduct=@LastProduct
/* ListPrice >=   LastProduct
2000.00     Touring-1000 Yellow, 60 */