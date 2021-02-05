--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Table exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isTable](@table varchar(max))
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@table) AND type in (N'U'))
		SET @Result=1
	RETURN @Result
END
