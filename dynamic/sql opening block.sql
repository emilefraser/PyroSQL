use [DB_name] -- change to your own db name
declare @crlf nchar(2)
set @crlf = char(0x0d) + char(0x0a);

select [Schema]=schema_name(p.schema_id), [Proc_Name]=p.name
, Num_of_LineCode=(len(m.definition) -len(replace(m.definition, @crlf, ''))) /2
from sys.sql_modules m
inner join sys.procedures p
on m.object_id = p.object_id;
GO