CREATE PROCEDURE [DSQLT].[_generateDSQLTStub]
@Schema [sysname], @Procedure [sysname], @Database [sysname], @Print BIT=0, @Iterate BIT=0
AS
BEGIN
declare @Stub varchar(max)
declare @Template varchar(max)
declare @ErrorMsg varchar(max)
SET @Stub='@@2'
SET @Template=''
if @Iterate=1 set @Stub='@'+@Stub
SET @ErrorMsg ='Template @1.'+@Stub+' nicht gefunden'

declare @rc int
-- Prüfen, ob Zielobjekt existiert
exec @rc=DSQLT.[@isProc] @Database,@Schema,@Procedure
if @rc=0  -- nein,dann Definition für Stub holen
	exec [DSQLT].[@getObjectDefinition] null,'@1',@Stub,@Template output
else 
	exec DSQLT._error 'Ziel existiert bereits'
-- falls geklappt,dann Objekt erzeugen
if @Template is not null
	exec DSQLT.[Execute] null,@Schema,@Procedure, @Database=@Database,@Template=@Template,@Print=@Print
else 
	exec DSQLT._error @ErrorMsg
END
