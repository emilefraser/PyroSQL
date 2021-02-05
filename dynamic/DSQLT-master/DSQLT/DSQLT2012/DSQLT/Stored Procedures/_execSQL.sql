CREATE PROCEDURE [DSQLT].[_execSQL]
@Database [sysname], @SQL NVARCHAR (MAX)=null, @Print BIT=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
Set @SQL='exec '+DSQLT.QuoteSB(@Database)+'..sp_executesql N'+DSQLT.QuoteSQ(@SQL)

IF @Print=0
	exec (@SQL)
	
IF @Print=1 
	print (@SQL)

RETURN 0
END
