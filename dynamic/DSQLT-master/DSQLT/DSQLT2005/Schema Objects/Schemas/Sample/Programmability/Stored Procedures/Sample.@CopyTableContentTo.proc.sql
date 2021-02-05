


CREATE PROCEDURE [Sample].[@CopyTableContentTo]
	@Database sysname
	,@Schema sysname
	,@Table sysname
	,@Print int=0
AS
	Declare @3 nvarchar(max)
	Declare @4 nvarchar(max)
	set @3 = DSQLT.ColumnList(@Schema+'.'+@Table)
	set @4 = DB_NAME()
	exec DSQLT.[Execute] '[Sample].@CopyTableContent',@Schema,@Table,@3,@4,@Database=@Database,@Print=@Print
RETURN
BEGIN
-- @0 = Zieldatenbank ist die aktuelle 
-- @1 = Schema
-- @2 = Tabelle 
-- @3 = Feldliste der Tabelle
-- @4 = Quelldatenbank
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert erlauben
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] ON

-- Tabelle löschen (Truncate geht nur, wenn sicher keine Foreign Keys auf die Tabelle verweisen)
BEGIN TRY
	truncate table [@1].[@2] 
END TRY
BEGIN CATCH 
	delete from [@1].[@2]  
END CATCH

-- Aus Quelldatenbank einfügen
insert into [@1].[@2] ("@3")
	select "@3" from [@4].[@1].[@2]
	
-- prüfen, ob Tabelle Identity Feld hat, falls ja, dann Insert abschalten
IF IDENT_SEED('[@1].[@2]') is not null
	SET IDENTITY_INSERT [@1].[@2] OFF

END


