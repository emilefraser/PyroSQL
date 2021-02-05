



CREATE PROCEDURE [DSQLT].[@CopyView]
@TargetDB [sysname], @Schema [sysname], @View [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyView',@Schema,@View,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isView] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isView] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropView] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	print '@2'
	END
END

