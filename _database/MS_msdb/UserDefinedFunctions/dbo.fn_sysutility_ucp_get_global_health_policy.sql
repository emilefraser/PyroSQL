SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE FUNCTION dbo.[fn_sysutility_ucp_get_global_health_policy](
    @rollup_object_type INT
    , @target_type INT
    , @resource_type INT
    , @utilization_type INT )
RETURNS INT 
AS
BEGIN
	DECLARE @health_policy_id INT
	
    -- Check if there is a global policy for that object type in a target type
	SELECT @health_policy_id = hp.health_policy_id
	FROM msdb.dbo.sysutility_ucp_policies hp
	WHERE hp.rollup_object_type = @rollup_object_type
	    AND hp.target_type = @target_type
	    AND hp.resource_type = @resource_type
	    AND hp.utilization_type = @utilization_type
	    AND hp.is_global_policy = 1
    
    -- If not found, check if there is a global policy for that object type at utility level. 
    -- This is the last resort, must find the global policy here.
    IF @health_policy_id = 0 OR @health_policy_id IS NULL
    BEGIN
		SELECT @health_policy_id = hp.health_policy_id
		FROM msdb.dbo.sysutility_ucp_policies hp
		WHERE hp.rollup_object_type = 0
		    AND hp.target_type = @target_type
		    AND hp.resource_type = @resource_type
		    AND hp.utilization_type = @utilization_type
		    AND hp.is_global_policy = 1    
    END	
    
	RETURN @health_policy_id
END

GO
