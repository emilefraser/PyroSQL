CREATE PROCEDURE dbo.TestWithExistsAndNestedSelectStarInlineIF
AS
IF EXISTS(SELECT * FROM sys.objects) SELECT * FROM sys.objects 
GO