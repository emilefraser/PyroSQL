CREATE PROCEDURE [DSQLT].[@GenerateSchema]
@Database [sysname], @Schema [sysname], @Print INT=0
AS
exec DSQLT.[Execute] '@GenerateSchema',@Schema,@Database=@Database,@Print=@Print
RETURN
BEGIN
exec DSQLT.DSQLT._generateSchema '[@0]','[@1]'
END
