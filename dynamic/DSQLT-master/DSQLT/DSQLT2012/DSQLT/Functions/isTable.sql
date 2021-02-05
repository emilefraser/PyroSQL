CREATE FUNCTION [DSQLT].[isTable]
(@table VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@table) AND type in (N'U'))
		SET @Result=1
	RETURN @Result
END
