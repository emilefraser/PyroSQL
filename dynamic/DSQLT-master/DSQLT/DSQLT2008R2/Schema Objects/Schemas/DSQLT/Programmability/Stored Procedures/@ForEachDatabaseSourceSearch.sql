

CREATE PROC [DSQLT].[@ForEachDatabaseSourceSearch]
@Pattern NVARCHAR (MAX),@DatabasePattern sysname ='%', @Print BIT=0
AS
declare @Database sysname
declare @Tempname char(36)
set @Tempname=cast(newid() as char(36))
Set @Database=DB_NAME()
SET @Pattern='%'+@Pattern+'%'

exec DSQLT.[Execute] null,@Tempname,@Template='SELECT TOP 0 * into [@1] from DSQLT.SourceSearch',@Print=@Print

declare @Cursor CURSOR ; SET @Cursor= CURSOR LOCAL STATIC FOR 
	select DatabaseQ from dsqlt.databases(@DatabasePattern)
exec DSQLT.iterate '[DSQLT].[@ForEachDatabaseSourceSearch]',@Cursor,@Pattern,@Tempname,@Database,@Print=@Print,@Database='@1'

exec DSQLT.[Execute] null,@Tempname,@Template='SELECT * from [@1]',@Print=@Print

exec DSQLT.[@DropTable] @Database=@Database, @Schema='dbo', @Table=@Tempname,@Print=@Print
RETURN
BEGIN
IF EXISTS (SELECT object_id from sys.sql_modules where definition like '@2')
	insert into [@4].dbo.[@3]
	select 
	@@servername as [Server]
	,DB_NAME() as [Database]
	,s.name as [Schema]
	,o.name as [Program] 
	,o.[type] 
	,o.type_desc 
	,m.definition
	from sys.sql_modules m
	join sys.objects o on m.object_id=o.object_id
	join sys.schemas s on o.schema_id=s.schema_id
	where m.definition like '@2'
END