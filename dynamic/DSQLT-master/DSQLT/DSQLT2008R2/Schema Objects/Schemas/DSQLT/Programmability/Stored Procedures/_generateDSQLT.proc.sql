


CREATE PROCEDURE [DSQLT].[_generateDSQLT]
@Database [sysname], @Print INT=0
AS
BEGIN
DECLARE @SourceDB sysname
DECLARE @Schema sysname
DECLARE @WildCard sysname

SET @SourceDB =DB_NAME()
SET @Schema ='DSQLT'
SET @WildCard =@Schema+'.%'

-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Func iterieren
print 'Functions'
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Function],@SourceDB as [Database] from [DSQLT].Functions(@WildCard) 
exec [DSQLT].[@@CopyFunction] @Cursor,@Database=@Database,@Print=@Print
-- über alle Prozeduren iterieren
print 'Procedures'
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB as [Database] from [DSQLT].[Procedures](@WildCard) 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print
print 'Tables'
-- über alle Tabellen iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Table],@SourceDB as [Database] from [DSQLT].Tables(@WildCard) 
exec [DSQLT].[@@CopyTable] @Cursor,@Database=@Database,@Print=@Print
	
print 'Schema @1'
set @Schema ='@1'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB as [Database] from [DSQLT].[Procedures](@WildCard) 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

END

