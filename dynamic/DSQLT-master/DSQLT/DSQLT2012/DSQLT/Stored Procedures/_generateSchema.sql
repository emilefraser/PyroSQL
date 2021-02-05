CREATE PROCEDURE [DSQLT].[_generateSchema]
@Database [sysname], @Schema [sysname], @Print BIT=0
AS
BEGIN
-- Schema erzeugen, falls noch nicht existiert
DECLARE @Result int
exec @Result=DSQLT.[@isSchema] @Database,@Schema
IF @Result=0
	exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- alle Tabellen erzeugen
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select @Schema,ParameterQ from [DSQLT].[Digits] (1,9)
exec DSQLT.[@@GenerateTable] @Cursor,@Database=@Database,@Print=@Print
	
END
