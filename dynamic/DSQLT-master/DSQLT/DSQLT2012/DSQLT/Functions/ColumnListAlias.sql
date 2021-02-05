

CREATE FUNCTION [DSQLT].[ColumnListAlias]
(@Table NVARCHAR (MAX)
,@Alias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result=''
	select @Result=DSQLT.Concat(@Alias+'.'+ColumnQ,' , ',@Result)
	from DSQLT.Columns(@Table)
	order by [Order]
	RETURN @Result
END


