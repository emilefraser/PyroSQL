
CREATE PROCEDURE dbo.TestWithExists
AS
IF EXISTS(SELECT * FROM sys.objects) BEGIN
	SELECT NAME FROM sys.objects 
end