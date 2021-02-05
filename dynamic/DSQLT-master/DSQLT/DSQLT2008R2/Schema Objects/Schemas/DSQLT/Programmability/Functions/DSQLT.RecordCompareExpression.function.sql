

CREATE FUNCTION [DSQLT].[RecordCompareExpression]
(@Source NVARCHAR (MAX)
, @Target NVARCHAR (MAX)
, @SourceAlias NVARCHAR (MAX)
, @TargetAlias NVARCHAR (MAX)
, @UseDefaultValues BIT
, @IgnoreColumnList NVARCHAR (MAX))
RETURNS NVARCHAR (MAX)
AS
BEGIN
	DECLARE @Result nvarchar(max)
	SET @Result =''
	SET @UseDefaultValues=isnull(@UseDefaultValues,0)
	SET @IgnoreColumnList=isnull(@IgnoreColumnList,'')
	
	select @Result=DSQLT.Concat(
		case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end
			,' or ',@Result)
	from DSQLT.ColumnCompare(@Source , @Target , @SourceAlias , @TargetAlias )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
		and [in_both_Tables]=1 and [is_primary_key]=0 and [is_Sync_Column]=0
	order by [Order]

	RETURN @Result
END