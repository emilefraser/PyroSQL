

CREATE Proc [DSQLT].[@GenerateSchema]
	@Database sysname
	, @Schema sysname
	, @Print int =0
as
exec DSQLT.[Execute] '@GenerateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
exec DSQLT.DSQLT._generateSchema '[@0]','[@1]'
END















