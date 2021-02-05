
-- führt eine Stored Proc in einer anderen Datenbank aus.
-- mit dem optionalen Parameter @Print kann der generierte Code ausgegeben anstatt ausgeführt werden.

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
