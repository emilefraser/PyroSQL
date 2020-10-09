SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_syscollector_delete_execution_log_tree]
    @log_id BIGINT,
    @from_collection_set    BIT = 1
AS
BEGIN
    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_operator'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_operator')
        RETURN(1) -- Failure
    END

    SET NOCOUNT ON;
    CREATE TABLE #log_ids (log_id BIGINT);
    
    WITH graph AS
    (
        SELECT log_id FROM dbo.syscollector_execution_log
        WHERE log_id = CASE @from_collection_set
            WHEN 1 THEN dbo.fn_syscollector_find_collection_set_root(@log_id)
            ELSE @log_id
        END
        UNION ALL
        SELECT leaf.log_id FROM dbo.syscollector_execution_log AS leaf
        INNER JOIN graph AS node ON (node.log_id = leaf.parent_log_id)
    )
    INSERT INTO #log_ids
    SELECT log_id
    FROM graph
    
    -- Delete all ssis log records pertaining to the selected logs
    DELETE FROM dbo.sysssislog
        FROM dbo.sysssislog AS s
        INNER JOIN dbo.syscollector_execution_log_internal AS l ON (l.package_execution_id = s.executionid)
        INNER JOIN #log_ids AS i ON i.log_id = l.log_id
        
    -- Then delete the actual logs
    DELETE FROM syscollector_execution_log_internal
        FROM syscollector_execution_log_internal AS l
        INNER Join #log_ids AS i ON i.log_id = l.log_id

    DROP TABLE #log_ids
    RETURN (0)
END

GO
