SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_policies 
AS
SELECT
    rhp.health_policy_id AS health_policy_id,
    p.policy_id AS policy_id,
    rhp.policy_name AS policy_name,
    rhp.rollup_object_type AS rollup_object_type,
    rhp.rollup_object_urn AS rollup_object_urn,
    rhp.target_type AS target_type,
    rhp.resource_type AS resource_type,
    rhp.utilization_type AS utilization_type,
    rhp.utilization_threshold AS utilization_threshold,
    rhp.is_global_policy AS is_global_policy
FROM [msdb].[dbo].[sysutility_ucp_health_policies_internal] rhp
INNER JOIN msdb.dbo.syspolicy_policies p ON p.name = rhp.policy_name

GO
