CREATE FUNCTION [DSQLT].[Concat]
(@Value NVARCHAR (MAX), @Delimiter NVARCHAR (MAX), @Result NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	RETURN @Result+case when LEN(@Result) = 0 then '' else @Delimiter end + @Value
END
