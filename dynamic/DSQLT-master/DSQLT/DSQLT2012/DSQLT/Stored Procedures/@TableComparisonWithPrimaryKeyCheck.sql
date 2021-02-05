CREATE PROCEDURE [DSQLT].[@TableComparisonWithPrimaryKeyCheck]
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
DECLARE	@PrimaryKeyExpressionWithNull NVARCHAR (MAX)
DECLARE	@PrimaryKeyField NVARCHAR (MAX)
DECLARE	@TemplateFields NVARCHAR (MAX)
DECLARE	@TemplatePKCheck NVARCHAR (MAX)
DECLARE	@TemplatePKError NVARCHAR (MAX)

SET	@TemplateFields =''
SET	@TemplatePKCheck =''
SET	@TemplatePKError =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @Target = DSQLT.QuoteNameSB(@TargetSchema+'.'+@TargetTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyCompareExpression = DSQLT.PrimaryKeyCompareExpression(@PKTable,'S','T')
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')
select top 1 @PrimaryKeyField = [ColumnQ] from DSQLT.Columns(@PKTable)
set @PrimaryKeyExpressionWithNull = DSQLT.PrimaryKeyConcatExpressionWithNull(@PKTable,'S')

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select ColumnQ as [@1]
		,case when @UseDefaultValues=1 then Compare_Columns_With_Null else Compare_Columns end as [@2]
	from DSQLT.ColumnCompare(@Source,@Target,'S','T')
	where in_both_Tables=1 and is_primary_key=0 and [is_Sync_Column]=0
			and charindex(ColumnQ,@IgnoreColumnList) = 0 

exec DSQLT.Iterate 'DSQLT.@TableComparisonSingleField',@Cursor
	,@Result
	,@Source
	,@Target 
	,@PrimaryKeyExpression -- @6
	,@PrimaryKeyCompareExpression -- @7
	,@Template=@TemplateFields OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCheck'
	,@Source -- @1
	,@PrimaryKeyExpression
	,@Result
	,@PrimaryKeyExpressionWithNull
	,@Template=@TemplatePKCheck OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCleanUp'
	,@Source -- @1
	,@PrimaryKeyExpression
	,@Template=@TemplatePKError OUTPUT
	,@Print=null

exec DSQLT.[Execute] 'DSQLT.@TableComparisonWithPrimaryKeyCheck' 
	,@Source -- @1
	,@Target -- @2
	,@Result -- @3
	,@PrimaryKeyExpression -- (Source) @4
	,@PrimaryKeyCompareExpression -- @5
	,@PrimaryKeyField -- @6
	,@TemplateFields -- @7
	,@TemplatePKCheck -- @8
	,@TemplatePKError -- @9
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @4 as int  -- to avoid Syntax error
DECLARE @5 as int  -- to avoid Syntax error
DECLARE @6 as int  -- to avoid Syntax error
BEGIN
IF '@3'='#T' 
	BEGIN
		SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
	END
	
-- hier wird das template für PrimaryKeyCheck eingefügt
/*@8*/
-- bis hierher
-- hier wird das template für PrimaryKeyErrorCleanUp eingefügt
/*@9*/
-- bis hierher

-- feststellen, ob es neue Datensätze gibt.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*INSERT*'  -- @ColumnName   leer, da nicht Feldspezifisch
,'EXISTS'
,null  -- Evaluate @ColumnName to TargetValue
FROM [@1].[@1] S  -- @Source
left outer join [@2].[@2] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]


-- feststellen, ob Datensätze gelöscht wurden.
INSERT INTO [@3].[@3]
([DSQLT_Source]
,[DSQLT_Target]
,[DSQLT_PrimaryKey]
,[DSQLT_ColumnName]
,[DSQLT_SourceValue]
,[DSQLT_TargetValue]
)
SELECT
 '@1'  -- @Source
,'@2'  -- @Target
,@4 -- @PrimaryKeyExpression"
,'*DELETE*'  -- @ColumnName   nicht Feldspezifisch
,null  
,'EXISTS'
FROM [@2].[@2] S  -- @Source
left outer join [@1].[@1] T  -- @Target
	on (@5=@5)  -- @PrimaryKeyCompareExpression
where T.[@6] is null   -- @ColumnCompareExpression]

-- hier wird das template für Feldvergleich eingefügt
/*@7*/
-- bis hierher

IF '@3'='#T' 
	BEGIN
	select * from #T
	drop table #T
	END
END
