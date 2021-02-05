CREATE PROCEDURE [DSQLT].[@DropFunction]
@Database [sysname], @Schema [sysname], @Function [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropFunction',@Schema,@Function,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP FUNCTION [@1].[@2]
END
