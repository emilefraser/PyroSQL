SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[syscollector_execution_log_full]
AS
SELECT 
        t.log_id,
        ISNULL(t.parent_log_id, 0) as parent_log_id,
        CASE 
            WHEN t.package_id IS NULL THEN SPACE(t.depth * 4) + c.name
            WHEN t.package_id = N'84CEC861-D619-433D-86FB-0BB851AF454A' THEN SPACE(t.depth * 4) + N'Master'
            ELSE SPACE(t.depth * 4) + p.name 
        END AS [name],
        t.[status],
        t.runtime_execution_mode,
        t.start_time,
        t.last_iteration_time,
        t.finish_time,
        t.duration,
        t.failure_message,
        t.operator,
        t.package_execution_id,
        t.collection_set_id
    FROM dbo.syscollector_execution_log_internal l
    CROSS APPLY dbo.fn_syscollector_get_execution_log_tree(l.log_id, 0) t
    LEFT OUTER JOIN dbo.syscollector_collection_sets c ON( c.collection_set_id = t.collection_set_id)
    LEFT OUTER JOIN dbo.sysssispackages p ON (p.id = t.package_id AND p.id != N'84CEC861-D619-433D-86FB-0BB851AF454A')
    WHERE l.parent_log_id IS NULL

GO
