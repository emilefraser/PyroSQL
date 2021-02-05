
CREATE PROC [DSQLT].[@SourceContains]
@Database [sysname],@Pattern NVARCHAR (MAX), @Print BIT=0
AS
SET NOCOUNT ON
-- um das Ergebnis zwischenzuspeichen
-- Template (unten zwischen BEGIN und END) holen
exec DSQLT.[Execute] '@SourceContains',@Pattern,@Database=@Database,@Print=@Print
-- Template ausführen, Ergebnis über tem. Tabelle holen
RETURN 
BEGIN
select 
S.name+'.'+O.name as SchemaProgram
,QUOTENAME(S.name)+'.'+QUOTENAME(O.name) as SchemaProgramQ
,s.name as [Schema]
,QUOTENAME(S.name) as [SchemaQ]
,o.name as [Program] 
,QUOTENAME(O.name) as [ProgramQ] 
,o.[type] 
,o.type_desc 
,m.definition
from sys.sql_modules m
join sys.objects o on m.object_id=o.object_id
join sys.schemas s on o.schema_id=s.schema_id
where m.definition like '%'+'@1'+'%'
END