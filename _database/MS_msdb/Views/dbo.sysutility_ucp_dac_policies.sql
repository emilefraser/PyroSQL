SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_dac_policies AS
(    
    SELECT dp.dac_name
        , dp.dac_server_instance_name
        , dp.dac_urn
        , dp.powershell_path
        , ISNULL(lp.policy_id, dp.policy_id) AS policy_id -- if exists get local (overridden) policy, else return global policy 
        , ISNULL(lp.is_global_policy, 1) AS is_global_policy
        , dp.resource_type
        , dp.target_type
        , dp.utilization_type
    FROM 
        (
            -- fetch the global policies 
            SELECT dd.dac_name
                , dd.dac_server_instance_name 
                , dd.urn AS dac_urn
                , dd.powershell_path AS powershell_path
                , gp.policy_id
                , gp.resource_type
                , gp.target_type
                , gp.utilization_type
            FROM msdb.dbo.sysutility_ucp_deployed_dacs dd
                , msdb.dbo.sysutility_ucp_policies gp
            WHERE gp.rollup_object_type = 1  
                AND gp.is_global_policy = 1    
        ) dp
        LEFT JOIN msdb.dbo.sysutility_ucp_policies lp -- fetch the local policies (if exists)
        ON lp.rollup_object_urn = dp.dac_urn 
            AND lp.rollup_object_type = 1
            AND lp.is_global_policy = 0
            AND lp.resource_type = dp.resource_type
            AND lp.target_type = dp.target_type
            AND lp.utilization_type = dp.utilization_type
)

GO
