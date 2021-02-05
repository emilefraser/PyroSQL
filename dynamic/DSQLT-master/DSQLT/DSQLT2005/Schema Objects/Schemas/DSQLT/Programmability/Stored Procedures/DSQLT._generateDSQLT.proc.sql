
CREATE PROCEDURE [DSQLT].[_generateDSQLT]
@Database [sysname], @Print INT=0
AS
BEGIN
DECLARE @SourceDB sysname
DECLARE @Schema sysname

SET @SourceDB =DB_NAME()
SET @Schema ='DSQLT'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Func iterieren
declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Function],@SourceDB from [DSQLT].Functions(@Schema+'.%') 
exec [DSQLT].[@@CopyFunction] @Cursor,@Database=@Database,@Print=@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB from [DSQLT].[Procedures](@Schema+'.%') 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

set @Schema ='@1'
-- Schema erzeugen, falls noch nicht existiert
exec DSQLT.[@CreateSchema] @Database,@Schema,@Print
-- über alle Prozeduren iterieren
SET @Cursor= CURSOR LOCAL STATIC FOR 
	select [Schema],[Procedure],@SourceDB from [DSQLT].[Procedures](@Schema+'.%') 
exec [DSQLT].[@@CopyProcedure] @Cursor,@Database=@Database,@Print=@Print

END
