SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE FUNCTION [dbo].[fn_syscollector_find_collection_set_root]
(
    @log_id BIGINT
)
RETURNS BIGINT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
    DECLARE @root_id BIGINT;

    -- Derive result using a CTE as the table is self-referencing
    WITH graph AS
    (
        -- select the anchor (specified) node
        SELECT log_id, parent_log_id FROM dbo.syscollector_execution_log WHERE log_id = @log_id
        UNION ALL
        -- select the parent node recursively
        SELECT node.log_id, node.parent_log_id FROM dbo.syscollector_execution_log node
        INNER JOIN graph AS leaf ON (node.log_id = leaf.parent_log_id)
    )
    SELECT @root_id = log_id FROM graph WHERE parent_log_id = 0;
    
    --Return result
    RETURN ISNULL(@root_id, @log_id)
END 

GO
