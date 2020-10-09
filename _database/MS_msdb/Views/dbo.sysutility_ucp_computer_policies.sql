SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_computer_policies AS
(    
    SELECT cp.physical_server_name
        , cp.computer_urn
        , cp.powershell_path
        , ISNULL(lp.policy_id, cp.policy_id) AS policy_id -- if exists get local (overridden) policy, else return global policy 
        , ISNULL(lp.is_global_policy, 1) AS is_global_policy
        , cp.resource_type
        , cp.target_type
        , cp.utilization_type
    FROM 
        (
            -- fetch the global policies 
            -- Should we be using "virtual_server_name" or "physical_server_name" here?
            SELECT co.physical_server_name AS physical_server_name
                , co.urn AS computer_urn
                , co.powershell_path AS powershell_path
                , gp.policy_id
                , gp.resource_type
                , gp.target_type
                , gp.utilization_type     
            FROM msdb.dbo.sysutility_ucp_computers co
                , msdb.dbo.sysutility_ucp_policies gp
            WHERE gp.rollup_object_type = 3  
                AND gp.is_global_policy = 1    
        ) cp
        LEFT JOIN msdb.dbo.sysutility_ucp_policies lp -- fetch the local policies (if exists)
        ON lp.rollup_object_urn = cp.computer_urn
            AND lp.rollup_object_type = 3
            AND lp.is_global_policy = 0
            AND lp.resource_type = cp.resource_type
            AND lp.target_type = cp.target_type
            AND lp.utilization_type = cp.utilization_type
)

GO
