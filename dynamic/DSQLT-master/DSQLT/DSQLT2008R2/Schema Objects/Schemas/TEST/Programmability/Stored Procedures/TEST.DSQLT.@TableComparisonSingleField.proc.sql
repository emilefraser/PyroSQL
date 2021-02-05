CREATE PROCEDURE [TEST].[DSQLT.@TableComparisonSingleField]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@TargetSchema sysname= null
	,@TargetTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@IgnoreColumnList varchar(max)=''
	,@UseDefaultValues bit=0
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Target NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@PrimaryKeyCompareExpression NVARCHAR (MAX)
DECLARE	@TargetPrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET		@Template =''
SET		@SourceSchema = 'Sample'
SET		@SourceTable = 'Source_Product'
SET		@TargetSchema = 'Sample'
SET		@TargetTable = 'Target_Product'
SET		@PrimaryKeySchema = 'Sample'
SET		@PrimaryKeyTable = 'Target_Product'

SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @Target = DSQLT.QuoteNameSB(@TargetSchema+'.'+@TargetTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyCompareExpression = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')
set @TargetPrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'T')

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ColumnQ as [@4]
		,case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end as [@5]
	from DSQLT.ColumnCompare(@Source,@Target,'S','T')
	where in_both_Tables=1 and is_primary_key=0 and [is_Sync_Column]=0
			and charindex(ColumnQ,@IgnoreColumnList) = 0 

exec DSQLT.Iterate 'DSQLT.@TableComparisonSingleField',@Cursor
	,@Result
	,@Source
	,@Target 
	,@PrimaryKeyExpression -- @6
	,@PrimaryKeyCompareExpression -- @7
	,@Template=@Template OUTPUT
	,@Print=null

print @Template