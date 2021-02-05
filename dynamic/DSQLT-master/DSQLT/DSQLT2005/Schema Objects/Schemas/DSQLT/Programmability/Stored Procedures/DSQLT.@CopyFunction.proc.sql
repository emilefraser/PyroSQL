
CREATE PROC [DSQLT].[@CopyFunction] 
	@TargetDB sysname
	,@Schema sysname
	,@Function sysname
	,@Print int=0
as
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyFunction',@Schema,@Function,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isFunc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isFunc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropFunction] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	END
END



