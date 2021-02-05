



CREATE Proc [DSQLT].[@CreateSchema]
	@Database sysname
	, @Schema sysname
	, @Print int =0
as
exec DSQLT.[Execute] '@CreateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
DECLARE @Result int
exec @Result=DSQLT.DSQLT.[@isSchema] '[@0]','[@1]'
IF @Result=0
	BEGIN
	declare @Template nvarchar(max)
	SET @Template ='CREATE SCHEMA [@1]'
	exec (@Template)
	END
END














