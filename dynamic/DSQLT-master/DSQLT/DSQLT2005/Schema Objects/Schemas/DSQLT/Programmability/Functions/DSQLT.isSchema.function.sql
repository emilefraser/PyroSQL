--
-- DSQLT by Henrik Bauer
-- OpenSource licensed under Ms-PL (http://www.microsoft.com/opensource/licenses.mspx#Ms-PL)
-- 
-- Description:	Check, if Schema exists
--
--------------------------------------------------------
CREATE FUNCTION [DSQLT].[isSchema](@schema sysname)
RETURNS bit
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID(@schema) or DSQLT.QuoteSB([name])= @schema)
		SET @Result=1
	RETURN @Result
END




