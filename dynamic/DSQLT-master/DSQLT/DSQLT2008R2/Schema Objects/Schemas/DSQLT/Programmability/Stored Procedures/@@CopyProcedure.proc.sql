
CREATE PROCEDURE [DSQLT].[@@CopyProcedure]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.iterate '@CopyProcedure',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0

