CREATE PROCEDURE [DSQLT].[_doTemplate]
@Database [sysname]=null, @Template NVARCHAR (MAX), @Print BIT=0
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()
	
if @Database=DB_NAME() -- kein Datenbankwechsel nötig
	BEGIN
	IF @Print=0 
			exec (@Template)  
	IF @Print=1 
			print (@Template)
	END
ELSE
		exec DSQLT._execSQL @Database,@Template,@Print   -- ausführen in der Zieldatenbank
RETURN 0
END
