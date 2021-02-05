
CREATE PROCEDURE [DSQLT].[@isFunc]
(
@Database sysname -- Datenbank
,@Schema sysname -- Schema
,@Table sysname -- Tabelle
,@Print bit =0 
)
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
DECLARE @Template varchar(max)
-- Template (unten zwischen BEGIN und END) holen
exec DSQLT.[Execute] '@isFunc',@Schema,@Table,@Template=@Template OUTPUT, @Print=null  -- unterdrückt die Ausführung, gibt nur an Template zurück!!
-- Template ausführen, Ergebnis über tem. Tabelle holen
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result 
BEGIN
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('[@1].[@2]') AND type in (N'AF',N'FN',N'FS',N'FT',N'IF',N'TF'))
		SELECT 1
	ELSE
		SELECT 0
END








