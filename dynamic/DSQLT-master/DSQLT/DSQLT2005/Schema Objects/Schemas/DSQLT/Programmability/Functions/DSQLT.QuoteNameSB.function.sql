--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote all nameparts of the objectname in text with square brackets.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteNameSB] (@Text nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN [DSQLT].[QuoteName] (@Text,'[')
END
