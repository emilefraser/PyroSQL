SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dba].[GetMissingIndex]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [dba].[GetMissingIndex]
AS


/* Missing index requests for this database */
SELECT 
    d.statement as table_name,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.avg_total_user_cost as avg_est_plan_cost,
    s.avg_user_impact as avg_est_cost_reduction,
    s.user_scans + s.user_seeks as times_requested
FROM sys.dm_db_missing_index_groups AS g
JOIN sys.dm_db_missing_index_group_stats as s on
    g.index_group_handle=s.group_handle
JOIN sys.dm_db_missing_index_details as d on
    g.index_handle=d.index_handle
JOIN sys.databases as db on 
    d.database_id=db.database_id
WHERE db.database_id=DB_ID();
' 
GO
