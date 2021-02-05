


CREATE PROCEDURE [DSQLT].[@DropSynonym]
@Database [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropSynonym',@Schema,@Table,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP SYNONYM [@1].[@2]
END