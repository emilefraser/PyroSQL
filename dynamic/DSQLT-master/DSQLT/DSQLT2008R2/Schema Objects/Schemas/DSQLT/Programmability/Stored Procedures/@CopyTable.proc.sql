

CREATE PROCEDURE [DSQLT].[@CopyTable]
@TargetDB [sysname], @Schema [sysname], @Table [sysname], @Print INT=0
AS
DECLARE @SourceDB sysname
SET @SourceDB =DB_NAME()
	exec DSQLT.[Execute] '@CopyTable',@Schema,@Table,@SourceDB,@Print=@Print,@Database=@TargetDB
RETURN
BEGIN
declare @Template varchar(max)
set @Template =''
declare @rc int
-- Prüfen, ob Quellobjekt existiert
exec @rc=DSQLT.DSQLT.[@isTable] '@3','@1','@2'
if @rc=1  -- ja
	BEGIN
	-- Prüfen, ob Zielobjekt gelöscht werden muss
	exec @rc=DSQLT.DSQLT.[@isTable] '@0','@1','@2'
	if @rc=1
		exec DSQLT.DSQLT.[@DropTable] '@0','@1','@2'
	-- dann Objekt erzeugen
	Select * 
	INTO [@0].[@1].[@2]
	from [@3].[@1].[@2]
	END
	print '@2'
END