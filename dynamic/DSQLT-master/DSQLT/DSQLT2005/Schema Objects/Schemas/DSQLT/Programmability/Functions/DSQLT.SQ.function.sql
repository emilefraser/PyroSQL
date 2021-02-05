--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Single Quote
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[SQ]( )
RETURNS CHAR (1)
AS
BEGIN
	RETURN ''''
END
