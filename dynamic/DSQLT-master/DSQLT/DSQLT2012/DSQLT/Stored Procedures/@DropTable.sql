CREATE PROCEDURE [DSQLT].[@DropTable]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropTable',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TABLE [@1].[@2]
END
