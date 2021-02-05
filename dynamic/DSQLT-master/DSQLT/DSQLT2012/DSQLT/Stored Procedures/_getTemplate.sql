CREATE PROCEDURE [DSQLT].[_getTemplate]
@DSQLTProc NVARCHAR (MAX), @Template NVARCHAR (MAX) OUTPUT
AS
BEGIN
declare @sql nvarchar(max)
declare @schema sysname
declare @begin int
declare @end int
declare @textzeilen nvarchar(max)
set @textzeilen='' 
-- zerlege Name in Schema und Objektname
SET @schema=PARSENAME(@DSQLTProc,2)
SET @DSQLTProc=PARSENAME(@DSQLTProc,1)
-- Beginnt per Konvention mit @ 
IF left(@DSQLTProc,1) <> '@' 
	SET @DSQLTProc = '@'+@DSQLTProc
-- Ist im Schema DSQLT, falls keines angegeben
IF @schema is null
	SET @schema = 'DSQLT'
-- Namen wieder zusammenbasteln
--SET @DSQLTProc = @schema+'.'+@DSQLTProc
SET @DSQLTProc = [DSQLT].[QuoteSB](@schema)+'.'+[DSQLT].[QuoteSB](@DSQLTProc)
--print @DSQLTProc
IF DSQLT.isProc(@DSQLTProc)=1
	BEGIN
	-- temporäre Tabelle, je Zeile Quelltext eine Tabellenzeile
	create table #t1 (z int identity(1,1), txt varchar(1000))
	-- Quelltext der prozedur in Tabelle einfügen
	insert into #t1 exec sp_helptext @DSQLTProc
	-- Kommentare strippen
	update #t1 set txt = left(txt,case when Charindex('--',txt)=0 then len(txt) else Charindex('--',txt)-1 end)
	-- Blanks links, rechts sowie Tabs und CR LF entfernen
	update #t1 set txt = ltrim(rtrim(replace(replace(replace(txt,CHAR(9),''),CHAR(10),''),CHAR(13),'')))
	-- leere zeilen löschen
	delete from #t1 where LEN(txt)=0 or txt is null
	-- erstes BEGIN
	select top 1 @begin=z from #t1 where txt = 'BEGIN' order by z
	-- und letztes END ermitteln
	select top 1 @end=z from #t1 where txt = 'END' order by z desc
	-- dazwischen ist unser Quelletext. Aufsammeln und Zeileumbruch ergänzen
	select @textzeilen=@textzeilen+txt+char(13)+char(10) from #t1 where z between @begin+1 and @end-1
	-- aufräumen
	drop table #t1
	-- Output Parameter setzen
	Set @Template= @textzeilen
	END
ELSE
	BEGIN
	-- Wenn noch in der Datenbank DSQLT gesucht wurde
	-- aber das Template im Schema DSQLT sein soll, dann nochmals in der Datenbank DSQLT suchen
		IF DB_NAME() <> 'DSQLT' and @schema = 'DSQLT'  	
			BEGIN
			exec [DSQLT].[DSQLT].[_getTemplate] @DSQLTProc, @Template OUTPUT
			END
		ELSE
			BEGIN
			exec DSQLT._error 'Template nicht gefunden'
			END
	END
RETURN
END
