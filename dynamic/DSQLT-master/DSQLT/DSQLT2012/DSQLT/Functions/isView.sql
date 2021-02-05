CREATE FUNCTION [DSQLT].[isView]
(@view VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@view) AND type in (N'V'))
		SET @Result=1
	RETURN @Result
END
