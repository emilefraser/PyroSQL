--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote text with single quotes.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteSQ] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN [DSQLT].[Quote] (@Text,DSQLT.SQ())
END
