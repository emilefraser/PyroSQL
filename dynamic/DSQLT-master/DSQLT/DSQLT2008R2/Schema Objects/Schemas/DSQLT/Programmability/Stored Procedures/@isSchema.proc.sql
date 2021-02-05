CREATE PROCEDURE [DSQLT].[@isSchema]
@Database [sysname], @Schema [sysname], @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
DECLARE @ResultTable TABLE(result int)
-- Ergebnis
DECLARE @Result int
-- Template (unten zwischen BEGIN und END) ausführen und Ergebnis nach @Result
DECLARE @Template varchar(max)
exec DSQLT.[Execute] '@isSchema',@Schema,@Template=@Template OUTPUT, @Print=null
INSERT INTO @ResultTable
	exec DSQLT._execSQL @Database,@Template,@Print
SELECT TOP 1 @Result=result from @ResultTable
RETURN @Result
BEGIN
	IF  EXISTS (SELECT * FROM sys.schemas WHERE schema_id = SCHEMA_ID('@1') or QUOTENAME([name])= '[@1]')
		SELECT 1
	ELSE
		SELECT 0
END
