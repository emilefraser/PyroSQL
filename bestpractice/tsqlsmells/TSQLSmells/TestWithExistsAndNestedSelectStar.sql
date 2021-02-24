CREATE PROCEDURE dbo.TestWithExistsAndNestedSelectStar
AS
IF EXISTS(SELECT * FROM sys.objects) BEGIN
	SELECT * FROM sys.objects 
end
GO