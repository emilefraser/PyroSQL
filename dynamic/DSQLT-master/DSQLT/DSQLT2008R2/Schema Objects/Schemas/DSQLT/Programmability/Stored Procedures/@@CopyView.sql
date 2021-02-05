

create PROCEDURE [DSQLT].[@@CopyView]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Iterate] '@CopyView',@Cursor,@SourceDB,@Database=@Database,@Print=@Print
RETURN 0