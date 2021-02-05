CREATE PROCEDURE [DSQLT].[@PrimaryKeyCheck]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@ResultSchema sysname= null
	,@ResultTable sysname= null
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE	@Result NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @Result = DSQLT.QuoteNameSB(@ResultSchema+'.'+@ResultTable)
if @Result is null SET @Result='#T'  -- Kennzeichen für temporäre Tabelle.
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'S')


DECLARE @PrimaryKeyExpressionWithNull nvarchar(max)
SET @PrimaryKeyExpressionWithNull =''
select @PrimaryKeyExpressionWithNull=
	DSQLT.Concat('isnull('+Source_concatvalue+',''*NULL*'')',' + ',@PrimaryKeyExpressionWithNull)
from DSQLT.ColumnCompare(@PKTable , @PKTable , '' , '' )
where [is_primary_key]=1
order by [Order]

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCheck' 
	,@Source -- @1
	,@PrimaryKeyExpression -- @2
	,@Result -- @3
	,@PrimaryKeyExpressionWithNull -- @4
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @2 as int  -- to avoid Syntax error
DECLARE @4 as int  -- to avoid Syntax error
BEGIN
IF '@3'='#T' 
	BEGIN
		SELECT TOP 0 * INTO #T FROM DSQLT.CompareResult
	END
	
-- feststellen, ob PrimaryKeyExpression NULL zurückgibt.
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
,''  -- @Target
,@4 -- @PrimaryKeyExpressionWithNull,
,'*PK CONTAINS NULL*'  -- @ColumnName   leer, da nicht Feldspezifisch
,@2
,null  --
FROM [@1].[@1] S  -- @Source
where @2 is null   -- @ColumnCompareExpression]


-- feststellen, ob es mehrere Datensätze mit gleicher PrimaryKeyExpression gibt.
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
,''  -- @Target
,@2 -- @PrimaryKeyExpressionWithNull,
,'*PK NOT UNIQUE*'  -- @ColumnName   leer, da nicht Feldspezifisch
,CAST(count(*) as varchar(max))  -- anzahl
,null  --
FROM [@1].[@1] S  -- @Source
where @2 is not null  
group by "@2"
having COUNT(*) > 1

IF '@3'='#T' 
	BEGIN
	select * from #T
	drop table #T
	END
END
