--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Quote text with square brackets.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteSB]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'[')
END

