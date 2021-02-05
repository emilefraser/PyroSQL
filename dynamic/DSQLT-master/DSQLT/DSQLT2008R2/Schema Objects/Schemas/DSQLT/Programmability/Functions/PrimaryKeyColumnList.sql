
CREATE FUNCTION [DSQLT].[PrimaryKeyColumnList]
(@Table NVARCHAR (MAX), @Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat(SourceColumnQ,' , ',@Result)
	from DSQLT.ColumnCompare(@Table , @Table , @Alias , @Alias )
	where [is_primary_key]=1
	order by [Order]

	RETURN @Result
END