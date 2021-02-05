CREATE PROCEDURE [DSQLT].[@DropTableType]
@Database [sysname], @Schema [sysname], @TableType [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropTableType',@Schema,@TableType,@Print=@Print,@Database=@Database
RETURN
BEGIN
DROP TYPE [@1].[@2]
END
