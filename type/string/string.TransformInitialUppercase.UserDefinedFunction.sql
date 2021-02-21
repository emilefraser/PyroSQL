CREATE OR ALTER FUNCTION string.TransformManyToSingle(
@String nvarchar(max), @SingleInput char(1))
RETURNS nvarchar(max)
AS
BEGIN
	RETURN REPLACE(REPLACE(REPLACE(REPLACE(@String,@SingleInput,'{0}{1}'),'{1}{0}',''),'{1}',''),'{0}',@SingleInput)
END
GO
