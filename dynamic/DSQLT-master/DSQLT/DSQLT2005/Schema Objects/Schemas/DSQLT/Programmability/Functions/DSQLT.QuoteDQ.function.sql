--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Embrace text with double quote.
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[QuoteDQ]
(@Text NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN [DSQLT].[QuoteSafe] (@Text,'"')
END





