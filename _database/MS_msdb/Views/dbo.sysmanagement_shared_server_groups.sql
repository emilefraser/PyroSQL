SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [dbo].[sysmanagement_shared_server_groups]
AS
(
    SELECT server_group_id, name, description, server_type, parent_id, is_system_object,
    (select COUNT(*) from [msdb].[dbo].[sysmanagement_shared_server_groups_internal] sgChild where sgChild.parent_id = sg.server_group_id) as num_server_group_children,
    (select COUNT(*) from [msdb].[dbo].[sysmanagement_shared_registered_servers_internal] rsChild where rsChild.server_group_id = sg.server_group_id) as num_registered_server_children
    FROM [msdb].[dbo].[sysmanagement_shared_server_groups_internal] sg
)

GO
