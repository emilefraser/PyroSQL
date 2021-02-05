

CREATE proc [Sample].[@ForEachDatabaseCheckDSQLTVersion] 
@Print bit=0
AS
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select * from dsqlt.databases('%')
exec DSQLT.iterate 'Sample.[@ForEachDatabaseCheckDSQLTVersion]',@Cursor=@Cursor,@Print=@Print,@Database='@1'
RETURN 
BEGIN
declare @rc int
declare @ok int
declare @Info varchar(max)
exec @ok=DSQLT.DSQLT.[@isSchema] '@0','DSQLT'
if @ok=1
	BEGIN
	set @Info='1.0'
	exec @rc=DSQLT.DSQLT.[@isFunc] '@0','DSQLT','Version'
	if @rc=1
		select @Info=DSQLT.Version()
	set @Info='Datenbank '+'@0'+', Version '+@Info
	print @Info
	END
END