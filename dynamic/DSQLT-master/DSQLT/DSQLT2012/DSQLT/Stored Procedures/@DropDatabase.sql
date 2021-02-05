CREATE PROCEDURE [DSQLT].[@DropDatabase]
@Database [sysname]=null, @Print BIT=0
AS
exec DSQLT.[Execute] '@DropDatabase' ,@p1=@Database,@Print=@Print
RETURN 0
BEGIN
DROP DATABASE [@1]
END
