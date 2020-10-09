SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_delete_shared_server_group]
    @server_group_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] WHERE server_group_id = @server_group_id)
    BEGIN
        RAISERROR (35004, -1, -1)
        RETURN(1)
    END;

    WITH ChildGroups (parent_id, server_group_id, name, server_type, server_level)
    AS
    (
        -- Anchor
        SELECT g.parent_id, g.server_group_id, g.name, g.server_type, 0 AS server_level
        FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] AS g
        WHERE g.server_group_id = @server_group_id
        UNION ALL
        -- Recursive definition
        SELECT r.parent_id, r.server_group_id, r.name, r.server_type, server_level + 1
        FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] AS r
        INNER JOIN ChildGroups AS children ON r.parent_id = children.server_group_id
    )
    -- Execute CTE to delete the hierarchy of server groups
    DELETE FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal]
        FROM ChildGroups children
        JOIN [msdb].[dbo].[sysmanagement_shared_server_groups_internal] ServerGroups
            ON children.server_group_id = ServerGroups.server_group_id
    RETURN (0)
END

GO
