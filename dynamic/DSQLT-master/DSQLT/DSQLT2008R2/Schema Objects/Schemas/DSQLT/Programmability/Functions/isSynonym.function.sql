CREATE FUNCTION [DSQLT].[isSynonym]
(@syn VARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@syn) AND type in (N'SN'))
		SET @Result=1
	RETURN @Result
END
