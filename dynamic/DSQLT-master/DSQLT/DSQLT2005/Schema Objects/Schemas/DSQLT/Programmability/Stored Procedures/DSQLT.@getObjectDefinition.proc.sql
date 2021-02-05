
CREATE PROCEDURE [DSQLT].[@getObjectDefinition]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Object sysname -- Object
,@Template nvarchar(max) output
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result nvarchar(max))
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
exec DSQLT.[Execute] '@getObjectDefinition',@Schema,@Object,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable 
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Template=result from @ResultTable
RETURN 
BEGIN
	Select OBJECT_DEFINITION(OBJECT_ID('[@1].[@2]'))
END









