-- Returns top 10 recent queries that waited for IO longer than 50 ms in average:
SELECT TOP 10 query_id, [wait time(sec)] = CAST(wait_time_ms /1000 AS NUMERIC(8,1)),
	start_time, end_time, query_text_id, execution_type_desc
FROM qpi.db_query_wait_stats_as_of(null)
WHERE category = 'Buffer IO'
AND wait_time_ms > 50
ORDER BY wait_time_ms DESC

-- Tip:
-- Use the following query to find the queries by id:
-- select * from qpi.db_queries where query_id = 38