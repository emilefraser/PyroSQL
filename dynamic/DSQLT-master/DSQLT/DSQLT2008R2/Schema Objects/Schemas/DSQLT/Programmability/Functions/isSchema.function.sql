CREATE FUNCTION [DSQLT].[isSchema]
(@schema [sysname])
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	-- check quoted name separatedly
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID(@schema) or DSQLT.QuoteSB([name])= @schema)
		SET @Result=1
	RETURN @Result
END
