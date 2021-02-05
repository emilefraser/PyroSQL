CREATE FUNCTION [DSQLT].[PrimaryKeyCompareExpression]
(@Table NVARCHAR (MAX), @SourceAlias NVARCHAR (MAX), @TargetAlias NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''
	
	select @Result=DSQLT.Concat(SourceColumnQ+'='+TargetColumnQ,' and ',@Result)
	from DSQLT.ColumnCompare(@Table ,@Table , @SourceAlias,  @TargetAlias  )
	where is_primary_key=1
	order by [Order]

	RETURN @Result
END
