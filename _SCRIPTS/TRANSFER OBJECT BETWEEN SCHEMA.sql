declare @theSchema SYSNAME, @theNewSchema sysname
declare @oneObj sysname, @aSQL nvarchar(1000)

set @theSchema = 'xxdeprecate'
set @theNewSchema = 'dbo'

-- migration of user-defined objects in [dbo]
declare @objCur cursor 
SET @objCur = CURSOR for
select quotename([name])
from sys.objects 
where (schema_id = schema_id(QUOTENAME('dbo')) or schema_id = schema_id(@theSchema))
 and type in ('V')
 AND name = 'vw_pres_DimTerminal'

open @objCur
fetch from @objCur into @oneObj
while @@fetch_status = 0 begin
 set @aSQL = 'ALTER SCHEMA '+  + CHAR(13) + CHAR(9) + QUOTENAME(@theNewSchema) + CHAR(13) + 'TRANSFER ' + CHAR(13) +  CHAR(9) + QUOTENAME(@theSchema) + '.' + @oneObj
 print @aSQL
 --exec sp_executeSQL @aSQL
 fetch next from @objCur into @oneObj
end



---- confirm by looking at the former and current schemas
--select * from sys.objects 
--where schema_id = schema_id(@theSchema) 
-- or schema_id = schema_id('dbo')
--order by schema_id
    
