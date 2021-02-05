CREATE FUNCTION [DSQLT].[InsertColumnList]
(	@Target NVARCHAR (MAX)
,	@IgnoreColumnList NVARCHAR (MAX)
)
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat([TargetColumnQ],' , ',@Result)
	from DSQLT.ColumnCompare(@Target ,@Target , '',  ''  )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
		and is_Sync_Column=0  -- added, 9.6.2010
	order by [Order]

	RETURN @Result
END
