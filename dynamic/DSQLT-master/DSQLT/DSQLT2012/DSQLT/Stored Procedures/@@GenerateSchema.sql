CREATE PROCEDURE [DSQLT].[@@GenerateSchema]
@Cursor CURSOR VARYING OUTPUT, @Database [sysname], @Print BIT=0
AS
exec DSQLT.iterate '@GenerateSchema',@Cursor,@Database=@Database,@Print=@Print
RETURN 0
