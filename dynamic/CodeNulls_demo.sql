/*
    Script to use the ScriptCountNulls function to script and 
    execute for each table in the database. 

    The table name is in the first column name.
*/
declare @script varchar(max)

/*
    The function requires a table name and a primary key field. Turns out it
    is a little trickier than imagined to obtain a primary key field programmatically.
    However actually any field flagged as non-nullable will do and if you find the 
    first non-nullable field in a table it is odds-on the pkey anyway. Thats
    what is happenning below.
*/
select @script = coalesce(@script, '')+dbo.ScriptCountNulls(o.name, c.name)
  from sys.objects o
  join (select object_id, min(column_id) as keyid
          from sys.columns 
         where is_nullable = 0  
      group by object_id) sq on sq.object_id = o.object_id
  join sys.columns c on c.object_id = o.object_id and c.column_id = keyid
 where type = 'U' -- user tables only

print @script 
exec (@script)
