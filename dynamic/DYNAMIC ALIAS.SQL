DECLARE @Legend varchar(32)='ProductName'
EXEC ('SELECT Name AS '+@Legend+' FROM AdventureWorks2008.Production.Product')