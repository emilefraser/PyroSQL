
CREATE PROCEDURE dbo.InsertMissingColumnSpecifiers
AS
 
    INSERT INTO aTable
	SELECT column1,column2 FROM dbo.SomeTable	

	INSERT INTO ttableb(f,g,h)
	SELECT a,b,c FROM dbo.tablec

