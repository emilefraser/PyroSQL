CREATE FUNCTION [DSQLT].[ColumnList]
(@Table NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END
