-- Index fragmentation

select object_name(s.object_id), i.name, s.avg_fragmentation_in_percent,
'ALTER INDEX ' + i.name +' ON [' + object_name(s.object_id) + '] REBUILD ',
* from sys.dm_db_index_physical_stats(DB_ID(), null, null, null, null)s
inner join sys.indexes i on i.index_id = s.index_id and i.object_id = s.object_id
order by 3 desc

-- https://ignas.me/tech/mssql-server-index-fragmentation/