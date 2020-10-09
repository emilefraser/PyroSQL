SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROC [dbo].[sp_syscollector_snapshot_dm_exec_requests_internal]
  @include_system_databases bit = 1
AS
BEGIN
    SET NOCOUNT ON

    -- Get the collection time as UTC time
    DECLARE @collection_time datetime
    SET @collection_time = GETDATE()

    SELECT
    CONVERT(INT, ROW_NUMBER() OVER (ORDER BY sess.session_id, ISNULL (req.request_id, -1), ISNULL (tasks.exec_context_id, -1)) ) AS row_id,
    -- IDs and Blocking IDs
    sess.session_id, 
    ISNULL (req.request_id, -1) AS request_id, 
    ISNULL (tasks.exec_context_id, -1) AS exec_context_id, 
    ISNULL (req.blocking_session_id, 0) AS blocking_session_id,
    CONVERT (BIT, CASE 
                    WHEN EXISTS (SELECT TOP 1 session_id FROM sys.dm_exec_requests bl WHERE bl.blocking_session_id = req.session_id) THEN 1
                    ELSE 0
                  END) AS is_blocking,
    ISNULL (waits.blocking_exec_context_id, 0) AS blocking_exec_context_id, 
    tasks.scheduler_id, 
    DB_NAME(req.database_id) as database_name, 
    req.[user_id], 

    -- State information
    LEFT (tasks.task_state, 10) AS task_state, 
    LEFT (req.status, 15) AS request_status, 
    LEFT (sess.status, 15) AS session_status,
    req.executing_managed_code, 

    -- Session information
    sess.login_time, 
    sess.is_user_process, 
    LEFT (ISNULL (sess.[host_name], ''), 20) AS [host_name], 
    LEFT (ISNULL (sess.[program_name], ''), 50) AS [program_name], 
    LEFT (ISNULL (sess.login_name, ''), 30) AS login_name, 

    -- Waits information
    LEFT (ISNULL (req.wait_type, ''), 45) AS wait_type, 
    LEFT (ISNULL (req.last_wait_type, ''), 45) AS last_wait_type, 
    ISNULL (waits.wait_duration_ms, 0) AS wait_duration_ms, 
    LEFT (ISNULL (req.wait_resource, ''), 50) AS wait_resource, 
    LEFT (ISNULL (waits.resource_description, ''), 140) AS resource_description,

    -- Transaction information
    req.transaction_id, 
    ISNULL(req.open_transaction_count, 0) AS open_transaction_count,
    COALESCE(req.transaction_isolation_level, sess.transaction_isolation_level) AS transaction_isolation_level,

    -- Request stats
    req.cpu_time AS request_cpu_time, 
    req.logical_reads AS request_logical_reads, 
    req.reads AS request_reads, 
    req.writes AS request_writes, 
    req.total_elapsed_time AS request_total_elapsed_time, 
    req.start_time AS request_start_time, 

    -- Session stats
    sess.memory_usage, 
    sess.cpu_time AS session_cpu_time, 
    sess.reads AS session_reads, 
    sess.writes AS session_writes, 
    sess.logical_reads AS session_logical_reads, 
    sess.total_scheduled_time AS session_total_scheduled_time, 
    sess.total_elapsed_time AS session_total_elapsed_time, 
    sess.last_request_start_time, 
    sess.last_request_end_time, 
    req.open_resultset_count AS open_resultsets, 
    sess.row_count AS session_row_count, 
    sess.prev_error, 
    tasks.pending_io_count, 

    -- Text/Plan handles
    ISNULL (req.command, 'AWAITING COMMAND') AS command,  
    req.plan_handle, 
    req.sql_handle, 
    req.statement_start_offset, 
    req.statement_end_offset,
    @collection_time AS collection_time
    FROM sys.dm_exec_sessions sess 
    LEFT OUTER MERGE JOIN sys.dm_exec_requests req  ON sess.session_id = req.session_id
    LEFT OUTER MERGE JOIN sys.dm_os_tasks tasks ON tasks.session_id = sess.session_id AND tasks.request_id = req.request_id AND tasks.task_address = req.task_address
    LEFT OUTER MERGE JOIN sys.dm_os_waiting_tasks waits ON waits.session_id = sess.session_id AND waits.waiting_task_address = req.task_address
    WHERE 
        sess.session_id <> @@SPID
        AND
        (
            (req.session_id IS NOT NULL AND (sess.is_user_process = 1 OR req.status COLLATE Latin1_General_BIN NOT IN ('background', 'sleeping')))    -- active request
                OR 
            (sess.session_id IN (SELECT DISTINCT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id != 0))                    -- not active, but head blocker
        )
        AND (@include_system_databases = 1 OR (req.database_id > 4 AND req.database_id < 32767))
    OPTION (FORCE ORDER)
END

GO
