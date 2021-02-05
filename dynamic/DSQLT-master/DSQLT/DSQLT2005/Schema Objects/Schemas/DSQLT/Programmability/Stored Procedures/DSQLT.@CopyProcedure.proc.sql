





CREATE PROC [DSQLT].[@CopyProcedure] 
	@TargetDB sysname
	,@Schema sysname
	,@Procedure sysname
	,@Print int=0
as
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyProcedure',@Schema,@Procedure,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isProc] '@3','@1','@2'
if @rc=1  -- ja,dann Definition holen
	exec DSQLT.DSQLT.[@getObjectDefinition] '@3','@1','@2',@Template output
-- falls geklappt
if @Template is not null
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isProc] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropProcedure] '@0','@1','@2'
	-- dann Objekt erzeugen
	exec (@Template)
	END
END



