
CREATE PROCEDURE [DSQLT].[@DropView]
@Database [sysname], @Schema [sysname], @View [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropView',@Schema,@View,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP VIEW [@1].[@2]
END