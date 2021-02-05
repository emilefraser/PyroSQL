CREATE FUNCTION [DSQLT].[UpdateColumnList]
(	@Source NVARCHAR (MAX)
,	@Target NVARCHAR (MAX)
,	@SourceAlias NVARCHAR (MAX)
,	@IgnoreColumnList NVARCHAR (MAX)
)
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''

	select @Result=DSQLT.Concat([ColumnQ]+' = '+Source_Value,' , ',@Result)
	from DSQLT.ColumnCompare(@Source ,@Target , @SourceAlias,  ''  )
	where [in_both_Tables]=1 and is_primary_key=0 
		and is_Sync_Column=0  -- added, 9.6.2010
	and charindex(ColumnQ,@IgnoreColumnList) = 0 
	order by [Order]

	RETURN @Result
END
