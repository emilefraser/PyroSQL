--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	CRLF
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[CRLF]
( )
RETURNS CHAR (2)
AS
BEGIN
	RETURN CHAR(13)+CHAR(10)
END


