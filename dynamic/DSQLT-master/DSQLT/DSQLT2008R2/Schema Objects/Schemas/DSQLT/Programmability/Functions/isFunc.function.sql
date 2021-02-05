CREATE FUNCTION [DSQLT].[isFunc]
(@fn NVARCHAR (MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @Result bit 
	SET @Result = 0
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@fn) AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SET @Result=1
	RETURN @Result
END
