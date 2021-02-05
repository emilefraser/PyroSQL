CREATE PROCEDURE [DSQLT].[@DropSchema]
@Database [sysname], @Schema [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@DropSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
DECLARE @Result int
exec @Result=DSQLT.DSQLT.[@isSchema] '[@0]','[@1]'
IF @Result=1
	BEGIN
	declare @Template nvarchar(max)
	SET @Template ='DROP SCHEMA [@1]'
	exec (@Template)
	END
END
