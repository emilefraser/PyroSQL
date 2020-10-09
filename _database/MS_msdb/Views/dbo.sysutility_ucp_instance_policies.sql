SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_instance_policies AS
(    
    SELECT sp.server_instance_name 
        , sp.smo_server_urn
        , sp.utility_server_urn
        , sp.powershell_path
        , ISNULL(lp.policy_id, sp.policy_id) AS policy_id -- if exists get local (overridden) policy, else return global policy 
        , ISNULL(lp.is_global_policy, 1) AS is_global_policy
        , sp.resource_type
        , sp.target_type
        , sp.utilization_type
    FROM (
            -- fetch the global policies 
            SELECT sv.Name AS server_instance_name
                , sv.urn AS smo_server_urn
                , N'Utility[@Name=''' + CONVERT(SYSNAME, SERVERPROPERTY(N'ServerName')) + N''']/' + sv.urn AS utility_server_urn
                , sv.powershell_path AS powershell_path
                , gp.policy_id
                , gp.resource_type
                , gp.target_type
                , gp.utilization_type
            FROM msdb.dbo.sysutility_ucp_instances sv
                , msdb.dbo.sysutility_ucp_policies gp
            WHERE gp.rollup_object_type = 2  
                AND gp.is_global_policy = 1    
        ) sp
        LEFT JOIN msdb.dbo.sysutility_ucp_policies lp -- fetch the local policies (if exists)
        ON lp.rollup_object_urn = sp.utility_server_urn 
            AND lp.rollup_object_type = 2
            AND lp.is_global_policy = 0
            AND lp.resource_type = sp.resource_type
            AND lp.target_type = sp.target_type
            AND lp.utilization_type = sp.utilization_type
)

GO
