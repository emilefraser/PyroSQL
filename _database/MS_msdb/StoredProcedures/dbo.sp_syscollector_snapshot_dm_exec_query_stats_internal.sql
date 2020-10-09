SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROC [dbo].[sp_syscollector_snapshot_dm_exec_query_stats_internal]
  @include_system_databases bit = 1
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @p1 datetime
    SET @p1 = GETDATE()

    SELECT 
        [sql_handle],
        statement_start_offset,
        statement_end_offset,
        -- Use ISNULL here and in other columns to handle in-progress queries that are not yet in sys.dm_exec_query_stats.  
        -- These values only come from sys.dm_exec_query_stats. If the plan does not show up in sys.dm_exec_query_stats 
        -- (first execution of a still-in-progress query, visible in sys.dm_exec_requests), these values will be NULL. 
        MAX (plan_generation_num) AS plan_generation_num,
        plan_handle,
        MIN (creation_time) AS creation_time, 
        MAX (last_execution_time) AS last_execution_time,
        SUM (execution_count) AS execution_count,
        SUM (total_worker_time) AS total_worker_time,
        MIN (min_worker_time) AS min_worker_time,           -- NULLable
        MAX (max_worker_time) AS max_worker_time,
        SUM (total_physical_reads) AS total_physical_reads,
        MIN (min_physical_reads) AS min_physical_reads,     -- NULLable
        MAX (max_physical_reads) AS max_physical_reads,
        SUM (total_logical_writes) AS total_logical_writes,
        MIN (min_logical_writes) AS min_logical_writes,     -- NULLable
        MAX (max_logical_writes) AS max_logical_writes,
        SUM (total_logical_reads) AS total_logical_reads,
        MIN (min_logical_reads) AS min_logical_reads,       -- NULLable
        MAX (max_logical_reads) AS max_logical_reads,
        SUM (total_clr_time) AS total_clr_time,
        MIN (min_clr_time) AS min_clr_time,                 -- NULLable
        MAX (max_clr_time) AS max_clr_time,
        SUM (total_elapsed_time) AS total_elapsed_time,
        MIN (min_elapsed_time) AS min_elapsed_time,         -- NULLable
        MAX (max_elapsed_time) AS max_elapsed_time,
        @p1 AS collection_time
    FROM
    (
        SELECT  
            [sql_handle],
            statement_start_offset,
            statement_end_offset,
            plan_generation_num,
            plan_handle,
            creation_time,
            last_execution_time,
            execution_count,
            total_worker_time,
            min_worker_time,
            max_worker_time,
            total_physical_reads,
            min_physical_reads,
            max_physical_reads,
            total_logical_writes,
            min_logical_writes,
            max_logical_writes,
            total_logical_reads,
            min_logical_reads,
            max_logical_reads,
            total_clr_time,
            min_clr_time,
            max_clr_time,
            total_elapsed_time,
            min_elapsed_time,
            max_elapsed_time 
        FROM sys.dm_exec_query_stats AS q
        -- Temporary workaround for VSTS #91422.  This should be removed if/when sys.dm_exec_query_stats reflects in-progress queries. 
        UNION ALL 
        SELECT 
            r.[sql_handle],
            r.statement_start_offset,
            r.statement_end_offset,
            ISNULL (qs.plan_generation_num, 0) AS plan_generation_num,
            r.plan_handle,
            ISNULL (qs.creation_time, r.start_time) AS creation_time,
            r.start_time AS last_execution_time,
            1 AS execution_count,
            -- dm_exec_requests shows CPU time as ms, while dm_exec_query_stats 
            -- uses microseconds.  Convert ms to us. 
            r.cpu_time * CAST(1000 as bigint) AS total_worker_time,
            qs.min_worker_time,     -- min should not be influenced by in-progress queries
            r.cpu_time * CAST(1000 as bigint) AS max_worker_time,
            r.reads AS total_physical_reads,
            qs.min_physical_reads,  -- min should not be influenced by in-progress queries
            r.reads AS max_physical_reads,
            r.writes AS total_logical_writes,
            qs.min_logical_writes,  -- min should not be influenced by in-progress queries
            r.writes AS max_logical_writes,
            r.logical_reads AS total_logical_reads,
            qs.min_logical_reads,   -- min should not be influenced by in-progress queries
            r.logical_reads AS max_logical_reads,
            qs.total_clr_time,      -- CLR time is not available in dm_exec_requests
            qs.min_clr_time,        -- CLR time is not available in dm_exec_requests
            qs.max_clr_time,        -- CLR time is not available in dm_exec_requests
            -- dm_exec_requests shows elapsed time as ms, while dm_exec_query_stats 
            -- uses microseconds.  Convert ms to us. 
            r.total_elapsed_time * CAST(1000 as bigint) AS total_elapsed_time,
            qs.min_elapsed_time,    -- min should not be influenced by in-progress queries
            r.total_elapsed_time * CAST(1000 as bigint) AS max_elapsed_time
        FROM sys.dm_exec_requests AS r 
        LEFT OUTER JOIN sys.dm_exec_query_stats AS qs ON r.plan_handle = qs.plan_handle AND r.statement_start_offset = qs.statement_start_offset 
            AND r.statement_end_offset = qs.statement_end_offset 
        WHERE r.sql_handle IS NOT NULL 
    ) AS query_stats 
    OUTER APPLY sys.dm_exec_sql_text (sql_handle) AS sql
    WHERE (@include_system_databases = 1 OR ([sql].dbid > 4 AND [sql].dbid < 32767))
    GROUP BY [sql_handle], plan_handle, statement_start_offset, statement_end_offset 
    ORDER BY [sql_handle], plan_handle, statement_start_offset, statement_end_offset
END

GO
