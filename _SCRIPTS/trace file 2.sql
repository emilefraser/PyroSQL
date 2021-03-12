SELECT * FROM:: fn_trace_gettable(@base_tracefile, default)
where eventcalss in (46,47,164) AND EventSubclass = 0 and databaseid <> 2

select * 
FROM sys.all_objects AS obj
LEFT OUTER JOIN sys.schemas AS s
on (obj.schema_id = s.schema_id)
where create_date > (GETDATE() - 7 )


select * 
FROM sys.all_objects AS obj
LEFT OUTER JOIN sys.schemas AS s
on (obj.schema_id = s.schema_id)
where create_date > (GETDATE() - 7 )