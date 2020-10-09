SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_instance_policy_type AS
(  
    -- Target types
    -- computer_type = 1
    -- volume_type = 6

    -- Resource types
    -- processor_type = 3
    -- space_type = 1

    SELECT sv.Name AS server_instance_name
        , CASE WHEN ((0 < ip.is_policy_overridden) OR (0 < cp.is_policy_overridden)) THEN 1 ELSE 0 END AS is_policy_overridden
    FROM msdb.dbo.sysutility_ucp_instances sv
        , (SELECT server_instance_name , SUM(CASE WHEN 0 < is_global_policy THEN 0 ELSE 1 END) AS is_policy_overridden
           FROM msdb.dbo.sysutility_ucp_instance_policies 
           GROUP BY server_instance_name) ip 
        , (SELECT physical_server_name, SUM(CASE WHEN 0 < is_global_policy THEN 0 ELSE 1 END) AS is_policy_overridden
           FROM msdb.dbo.sysutility_ucp_computer_policies  
           GROUP BY physical_server_name) cp 
    WHERE ip.server_instance_name = sv.Name
        AND cp.physical_server_name = sv.ComputerNamePhysicalNetBIOS
) 

GO
