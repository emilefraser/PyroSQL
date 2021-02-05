--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Helperfunction for building (comma)separated List
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Concat] (@Value nvarchar(max) ,@Delimiter nvarchar(max), @Result nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN @Result+case when LEN(@Result) = 0 then '' else @Delimiter end + @Value
END





