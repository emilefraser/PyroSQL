SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[syscollector_execution_log] AS
    SELECT 
        log_id, 
        ISNULL(parent_log_id, 0) as parent_log_id, 
        collection_set_id, 
        collection_item_id,
        start_time,
        last_iteration_time,
        finish_time,
        runtime_execution_mode,
        [status],
        operator,
        package_id,
        msdb.dbo.fn_syscollector_get_package_path(package_id) as package_name,
        package_execution_id,
        failure_message
    FROM dbo.syscollector_execution_log_internal;

GO
