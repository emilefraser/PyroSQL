
CREATE FUNCTION [DSQLT].[PrimaryKeyConcatExpression]
(@Table NVARCHAR (MAX), @Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat(Source_concatvalue,' + ',@Result)
	from DSQLT.ColumnCompare(@Table , @Table , @Alias , @Alias )
	where [is_primary_key]=1
	order by [Order]

	RETURN @Result
END