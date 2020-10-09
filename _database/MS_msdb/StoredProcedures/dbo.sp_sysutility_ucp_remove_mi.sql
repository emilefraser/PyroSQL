SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_ucp_remove_mi]
@instance_id int
WITH EXECUTE AS OWNER
AS
BEGIN
   DECLARE @retval              INT


    IF (@instance_id IS NULL)
    BEGIN
        RAISERROR(14043, -1, -1, 'instance_id', 'sp_sysutility_ucp_remove_mi')
        RETURN(1)
    END

    DECLARE @instance_name SYSNAME
    SELECT @instance_name = instance_name 
    FROM msdb.dbo.sysutility_ucp_managed_instances_internal 
    WHERE instance_id = @instance_id
    
    -- Clean up managed instance health states and update dashboard stats
    -- This block comes before the delete from sysutility_ucp_managed_instances_internal
    -- so we can retrieve the instance name in case there's an error inside the block and
    -- this sp is rerun
    IF EXISTS (SELECT 1 FROM msdb.dbo.sysutility_ucp_mi_health_internal WHERE mi_name = @instance_name)
    BEGIN
        DECLARE @health_state_id INT
        SELECT @health_state_id = latest_health_state_id FROM msdb.dbo.sysutility_ucp_processing_state_internal
        
        -- Delete the managed instance record
        DELETE FROM msdb.dbo.sysutility_ucp_mi_health_internal WHERE mi_name = @instance_name

        -- Re-compute the dashboard health stats
        DELETE FROM msdb.dbo.sysutility_ucp_aggregated_mi_health_internal WHERE set_number = @health_state_id
        EXEC msdb.dbo.sp_sysutility_ucp_calculate_aggregated_mi_health @health_state_id   
        
        -- Delete the health records of DACs in the removed instance.
        DELETE FROM msdb.dbo.sysutility_ucp_dac_health_internal WHERE dac_server_instance_name = @instance_name        
        
        -- Re-compute the DAC health stats in the dashboard
        DELETE FROM msdb.dbo.sysutility_ucp_aggregated_dac_health_internal WHERE set_number = @health_state_id
        EXEC msdb.dbo.sp_sysutility_ucp_calculate_aggregated_dac_health @health_state_id   
    END

    DELETE [dbo].[sysutility_ucp_managed_instances_internal] 
        WHERE instance_id = @instance_id

    SELECT @retval = @@error
    RETURN(@retval)
END

GO
