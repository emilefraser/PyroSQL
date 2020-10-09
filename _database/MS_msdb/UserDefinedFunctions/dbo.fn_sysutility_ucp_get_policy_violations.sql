SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_policy_violations](@policy_name SYSNAME, @target_query_expression NVARCHAR(max))
RETURNS @data TABLE 
( health_state_id BIGINT ) 
AS
BEGIN

   INSERT INTO @data
    SELECT hs.detail_id
    FROM msdb.dbo.sysutility_ucp_policy_violations hs
    INNER JOIN msdb.dbo.syspolicy_policies p ON hs.policy_id = p.policy_id
    WHERE (hs.target_query_expression_with_id LIKE +'%'+@target_query_expression+'%' ESCAPE '\'
    OR hs.target_query_expression LIKE +'%'+@target_query_expression+'%')
    AND hs.result = 0
    AND p.name = @policy_name
    
   RETURN 
END

GO
