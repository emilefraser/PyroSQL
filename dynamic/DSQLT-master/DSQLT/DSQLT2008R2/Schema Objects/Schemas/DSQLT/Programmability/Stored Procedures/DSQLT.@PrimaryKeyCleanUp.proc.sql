create PROCEDURE [DSQLT].[@PrimaryKeyCleanUp]
	 @SourceSchema sysname = null
	,@SourceTable sysname= null
	,@PrimaryKeySchema sysname=null
	,@PrimaryKeyTable sysname=null
	,@Create varchar(max)=null
	,@Print bit = 0
AS
DECLARE	@Source NVARCHAR (MAX)
DECLARE @PKTable NVARCHAR (MAX)   -- Tabelle mit Primärkeydefinition
DECLARE	@PrimaryKeyExpression NVARCHAR (MAX)
DECLARE	@Template NVARCHAR (MAX)

SET	@Template =''
SET @Source=DSQLT.QuoteNameSB(@SourceSchema+'.'+@SourceTable)
set @PKTable = DSQLT.QuoteNameSB(@PrimaryKeySchema+'.'+@PrimaryKeyTable)
if @PKTable is null SET @PKTable=@Source
set @PrimaryKeyExpression = DSQLT.PrimaryKeyConcatExpression(@PKTable,'')

exec DSQLT.[Execute] 'DSQLT.@PrimaryKeyCleanUp' 
	,@Source -- @1
	,@PrimaryKeyExpression -- @2
	,@Create=@Create
	,@Print=@Print

RETURN 
DECLARE @2 as int  -- to avoid Syntax error
BEGIN
-- wenn NULL vorkommt
	DELETE FROM [@1].[@1] 
	where @2 is null   
-- mehrfache Datensätze
	DELETE FROM [@1].[@1] 
	where @2 in (
		select @2 FROM [@1].[@1]  
		where @2 is not null  
		group by "@2"
		having COUNT(*) > 1
		)
END