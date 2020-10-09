SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION dbo.[fn_sysutility_ucp_get_applicable_policy](
    @rollup_object_urn NVARCHAR(4000)
    , @rollup_object_type INT
    , @target_type INT
    , @resource_type INT
    , @utilization_type INT )
RETURNS INT 
AS
BEGIN
   DECLARE @health_policy_id INT
	
    -- Check if there is an overridden policy for the rollup object
    SELECT @health_policy_id = hp.health_policy_id
    FROM msdb.dbo.sysutility_ucp_policies hp
    WHERE hp.rollup_object_urn = @rollup_object_urn
        AND hp.rollup_object_type = @rollup_object_type
        AND hp.target_type = @target_type
        AND hp.resource_type = @resource_type
        AND hp.utilization_type = @utilization_type
    
    -- If no overridden policy exist, get the global policy
    -- Check if the specific rollup_object has the global policy
    IF @health_policy_id = 0 OR @health_policy_id IS NULL
    BEGIN
		SELECT @health_policy_id = msdb.dbo.fn_sysutility_ucp_get_global_health_policy(@rollup_object_type
                                                                                , @target_type
                                                                                , @resource_type
                                                                                , @utilization_type)
    END
    
	RETURN @health_policy_id
     
END

GO
