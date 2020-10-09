SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[fn_syscollector_get_execution_log_tree] 
(
     @log_id                BIGINT,
     @from_collection_set    BIT = 1
) 
RETURNS TABLE
AS
RETURN
(
    -- Derive result using a CTE as the table is self-referencing
    WITH graph AS 
    (
        -- select the anchor (specified) node
        SELECT 
            log_id,
            parent_log_id,
            collection_set_id,
            start_time,
            last_iteration_time,
            finish_time,
            runtime_execution_mode,
            operator,
            [status],
            package_id,
            package_execution_id,
            failure_message,
            0 AS depth 
        FROM dbo.syscollector_execution_log
        WHERE log_id = CASE @from_collection_set
            WHEN 1 THEN dbo.fn_syscollector_find_collection_set_root(@log_id)
            ELSE @log_id
        END 
        -- select the child nodes recursively
        UNION ALL
        SELECT 
            leaf.log_id,
            leaf.parent_log_id,
            leaf.collection_set_id,
            leaf.start_time,
            leaf.last_iteration_time,
            leaf.finish_time,
            leaf.runtime_execution_mode,
            leaf.operator,
            leaf.[status],
            leaf.package_id,
            leaf.package_execution_id,
            leaf.failure_message,
            node.depth + 1 AS depth
        FROM dbo.syscollector_execution_log AS leaf
        INNER JOIN graph AS node ON (node.log_id = leaf.parent_log_id)
    )
    SELECT 
        log_id,
        parent_log_id,
        collection_set_id,
        start_time,
        last_iteration_time,
        finish_time,
        CASE 
            WHEN finish_time IS NOT NULL THEN DATEDIFF(ss, start_time, finish_time) 
            WHEN last_iteration_time IS NOT NULL THEN DATEDIFF(ss, start_time, last_iteration_time) 
            ELSE 0
        END AS duration,
        runtime_execution_mode,
        operator,
        [status],
        package_id,
        package_execution_id,
        failure_message,
        depth 
    FROM graph
) 

GO
