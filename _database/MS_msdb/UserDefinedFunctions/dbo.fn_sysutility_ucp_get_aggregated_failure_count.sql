SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION [dbo].[fn_sysutility_ucp_get_aggregated_failure_count](@policy_name SYSNAME, @target_query_expression NVARCHAR(max))
RETURNS INT 
AS
BEGIN
   DECLARE @count INT
   SET @count = 0;

    SELECT @count = COUNT(hs.result) 
    FROM msdb.dbo.sysutility_ucp_policy_violations hs
    INNER JOIN msdb.dbo.syspolicy_policies p ON hs.policy_id = p.policy_id
    WHERE (hs.target_query_expression_with_id LIKE +'%'+@target_query_expression+'%' ESCAPE '\'
    OR hs.target_query_expression LIKE +'%'+@target_query_expression+'%')
    AND hs.result = 0
    AND p.name = @policy_name

   RETURN @count
END

GO
