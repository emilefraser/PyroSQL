CREATE FUNCTION [DSQLT].[SelectValueList]
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
	-- Achtung : für den Aufruf von DSQLT.ColumnCompare werden @Source und @Target vertauscht.
	select @Result=
		DSQLT.Concat(
			case 
			when is_Source_nullable = 1 and in_both_Tables = 0 then ' null '
			when in_both_Tables = 0 then Default_Value
			when is_Source_nullable =0 and is_Target_nullable = 1 then Target_Value_With_Null
			else Target_Value
			end
		,' , ',@Result)
	from DSQLT.ColumnCompare(@Target ,@Source , @SourceAlias,  @SourceAlias  )
	where charindex(ColumnQ,@IgnoreColumnList) = 0 
			and is_Sync_Column=0  -- added, 9.6.2010
	order by [Order]
	
	RETURN @Result
END
