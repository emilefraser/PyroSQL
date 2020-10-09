SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW dbo.sysutility_ucp_policy_target_conditions 
AS
SELECT
    tc.rollup_object_type AS rollup_object_type,
    tc.target_type AS target_type,
    tc.resource_type AS resource_type,
    tc.utilization_type AS utilization_type, 
    tc.facet_name AS facet_name,
    tc.attribute_name AS attribute_name,
    tc.operator_type as operator_type,
    tc.property_name as property_name
FROM msdb.[dbo].[sysutility_ucp_policy_target_conditions_internal] tc

GO
