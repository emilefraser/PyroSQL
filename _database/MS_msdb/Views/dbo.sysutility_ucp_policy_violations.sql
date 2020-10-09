SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW dbo.sysutility_ucp_policy_violations 
AS
    SELECT pv.health_policy_id
        , pv.policy_id
        , pv.policy_name
        , pv.history_id
        , pv.detail_id
        , pv.target_query_expression
        , pv.target_query_expression_with_id
        , pv.execution_date
        , pv.result
    FROM dbo.sysutility_ucp_policy_violations_internal pv

GO
