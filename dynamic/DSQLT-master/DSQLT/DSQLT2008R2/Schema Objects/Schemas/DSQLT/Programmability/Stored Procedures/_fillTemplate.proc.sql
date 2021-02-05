
-- ersetzt in einem SQL-Quelltext (@Template) die standardisierten Parameter @0 - @9 mit den Werten aus @p0 - @p9. 
-- das Ergebnis wird in @Template zurückgegeben.
-- falls der Parameter @p0 NULL enthält, wird dieser mit dem aktuellen Datenbank-Namen vorbesetzt.
-- dies entspricht der standardmäßigen Verwendung von @0.

CREATE PROCEDURE [DSQLT].[_fillTemplate]
@p1 NVARCHAR (MAX)=null, @p2 NVARCHAR (MAX)=null, @p3 NVARCHAR (MAX)=null, @p4 NVARCHAR (MAX)=null, @p5 NVARCHAR (MAX)=null, @p6 NVARCHAR (MAX)=null, @p7 NVARCHAR (MAX)=null, @p8 NVARCHAR (MAX)=null, @p9 NVARCHAR (MAX)=null, @Database NVARCHAR (MAX)=null, @Template NVARCHAR (MAX) OUTPUT
AS
BEGIN
if @Database is null
	SET @Database=DB_NAME()

declare @pos int 
declare @c char(1)
set @pos=0
while @pos >= 0 -- wird innerhalb der Schleife abgebrochen
begin
	set @pos=Charindex('@',@Template,@pos+1) 
	if @pos<=0 or @pos>=LEN(@Template)
		break
	
	set @c=SUBSTRING(@Template,@pos+1,1)
	if @c ='0' 	exec DSQLT._replaceParameter '@0',@Template OUTPUT,@Database,@pos OUTPUT
	if @c ='1' 	exec DSQLT._replaceParameter '@1',@Template OUTPUT,@p1,@pos OUTPUT
	if @c ='2' 	exec DSQLT._replaceParameter '@2',@Template OUTPUT,@p2,@pos OUTPUT
	if @c ='3' 	exec DSQLT._replaceParameter '@3',@Template OUTPUT,@p3,@pos OUTPUT
	if @c ='4' 	exec DSQLT._replaceParameter '@4',@Template OUTPUT,@p4,@pos OUTPUT
	if @c ='5' 	exec DSQLT._replaceParameter '@5',@Template OUTPUT,@p5,@pos OUTPUT
	if @c ='6' 	exec DSQLT._replaceParameter '@6',@Template OUTPUT,@p6,@pos OUTPUT
	if @c ='7' 	exec DSQLT._replaceParameter '@7',@Template OUTPUT,@p7,@pos OUTPUT
	if @c ='8' 	exec DSQLT._replaceParameter '@8',@Template OUTPUT,@p8,@pos OUTPUT
	if @c ='9' 	exec DSQLT._replaceParameter '@9',@Template OUTPUT,@p9,@pos OUTPUT
		
	if @pos<=0 or @pos>=LEN(@Template)
		break
end

RETURN
END

