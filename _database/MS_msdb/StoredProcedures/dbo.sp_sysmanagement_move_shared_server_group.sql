SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysmanagement_move_shared_server_group]
    @server_group_id INT,
    @new_parent_id INT
AS
BEGIN
    IF (@new_parent_id IS NULL) OR 
        NOT EXISTS (SELECT * FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] WHERE server_group_id = @new_parent_id)
    BEGIN
        RAISERROR (35001, -1, -1)
        RETURN(1)
    END

    IF (@new_parent_id IS NOT NULL)
        AND ((SELECT server_type FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] WHERE server_group_id = @new_parent_id)
                <>
             (SELECT server_type FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] WHERE server_group_id = @server_group_id))
    BEGIN
        RAISERROR (35002, -1, -1)
        RETURN(1)
    END

    DECLARE @DeletedGroups TABLE
    (
        server_group_id int
    );

    -- Check if the destination group you're moving to isn't already a descendant of the current group
    WITH ChildGroups (parent_id, server_group_id, server_level)
    AS
    (
        -- Anchor
        SELECT g.parent_id, g.server_group_id, 0 AS server_level
        FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] AS g
        WHERE g.server_group_id = @server_group_id
        UNION ALL
        -- Recursive definition
        SELECT r.parent_id, r.server_group_id, server_level + 1
        FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] AS r
        INNER JOIN ChildGroups AS children ON r.parent_id = children.server_group_id
    )
    -- Execute CTE
    INSERT INTO @DeletedGroups
    SELECT server_group_id FROM ChildGroups

    IF (SELECT COUNT(*) FROM @DeletedGroups WHERE server_group_id = @new_parent_id) > 0
    BEGIN
        RAISERROR (35003, -1, -1)
        RETURN(1)
    END
    
    UPDATE [msdb].[dbo].[sysmanagement_shared_server_groups_internal]
        SET parent_id = @new_parent_id
    WHERE
        server_group_id = @server_group_id
    RETURN (0)
END

GO
