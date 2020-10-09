SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_policy_check_conditions 
AS
SELECT
    cc.target_type AS target_type,
    cc.resource_type AS resource_type,
    cc.utilization_type AS utilization_type,
    cc.facet_name AS facet_name,
    cc.attribute_name AS attribute_name,
    cc.operator_type AS operator_type,
    cc.property_name AS property_name
FROM msdb.[dbo].[sysutility_ucp_policy_check_conditions_internal] cc

GO
