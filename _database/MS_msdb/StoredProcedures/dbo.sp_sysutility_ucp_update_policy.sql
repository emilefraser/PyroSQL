SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_ucp_update_policy] 
   @resource_health_policy_id INT
   , @utilization_threshold INT
WITH EXECUTE AS OWNER
AS
BEGIN

    DECLARE @retval INT
    DECLARE @null_column    SYSNAME
    
    SET @null_column = NULL

    IF (@resource_health_policy_id IS NULL OR @resource_health_policy_id = 0)
        SET @null_column = '@resource_health_policy_id'
    ELSE IF (@utilization_threshold IS NULL OR @utilization_threshold < 0 OR @utilization_threshold > 100)
        SET @null_column = '@utilization_threshold'    

    IF @null_column IS NOT NULL
    BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_update_policy')
        RETURN(1)
    END

    IF NOT EXISTS (SELECT * FROM dbo.sysutility_ucp_health_policies_internal WHERE health_policy_id = @resource_health_policy_id)
    BEGIN
        RAISERROR(22981, -1, -1)
        RETURN(1)
    END
    
    UPDATE dbo.sysutility_ucp_health_policies_internal
    SET utilization_threshold = @utilization_threshold
    WHERE health_policy_id = @resource_health_policy_id
    
    SELECT @retval = @@error
    RETURN(@retval)
END

GO
