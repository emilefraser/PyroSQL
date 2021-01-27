DBCC SHOW_STATISTICS(TableName,IndexName)

-- We can also filter this by object name further
SELECT OBJECT_NAME(object_id)
	, user_seeks
	, user_scans
	, user_lookups
	, user_updates
FROM sys.dm_db_index_usage_stats
WHERE DB_NAME(database_id) = 'DatabaseName'
