
CREATE PROCEDURE dbo.InsertSelectStar
AS
 
    INSERT INTO aTable(Col1,Col2)
	SELECT * FROM dbo.SomeTable	
