--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Cleanup Searchpattern with Escaping [,%,_
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[Escape] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN REPLACE(REPLACE(REPLACE(@Text,'[','[[]'),'%','[%]'),'_','[_]')
END




