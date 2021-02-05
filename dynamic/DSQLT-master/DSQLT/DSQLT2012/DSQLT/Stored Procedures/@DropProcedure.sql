CREATE PROCEDURE [DSQLT].[@DropProcedure]
@Database [sysname], @Schema [sysname], @Procedure [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropProcedure',@Schema,@Procedure,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP PROCEDURE [@1].[@2]
END
