--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Database exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isDatabase] (@db sysname)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.databases WHERE [name] = @db or QUOTENAME([name]) = @db)
		SET @Result=1
	RETURN @Result
END



