CREATE FUNCTION [DSQLT].[isProc]
(@sp NVARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@sp) AND type in (N'P', N'PC'))
		SET @Result=1
	RETURN @Result
END
