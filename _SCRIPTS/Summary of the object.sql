select * from sys.schemas
select * from sys.database_principals
select * from sys.objects
select count(1) as [21558_lib_remote_count]
from sys.objects
where schema_id = schema_id('[21558_lib_remote]')
 and type in ('U', 'V', 'P', 'FN')
select count(1) as dbo_count
from sys.objects
where schema_id = schema_id('dbo')
 and type in ('U', 'V', 'P', 'FN')