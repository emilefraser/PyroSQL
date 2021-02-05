--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Synonym exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isSynonym](@syn varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@syn) AND type in (N'SN'))
		SET @Result=1
	RETURN @Result
END


