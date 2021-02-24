
CREATE PROCEDURE dbo.TestCrossServerJoin
AS
	SELECT NAME FROM ServerName.DataBaseName.SchemaName.MyTable
