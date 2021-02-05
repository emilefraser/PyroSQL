CREATE PROCEDURE [Sample].[@@CopyTableContentFrom]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname]=null, @Print BIT=0
AS
if @Database is null SET @Database=DB_NAME()
	exec DSQLT.iterate '[Sample].[@CopyTableContentFrom]',@Cursor,@Database,@Print=@Print
RETURN 0
