SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_calculate_health 
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    -- Snapshot isolation prevents the nightly purge jobs that delete much older data from blocking us. 
    SET TRANSACTION ISOLATION LEVEL SNAPSHOT; 

    DECLARE @new_set_number INT
    DECLARE @myTableVar table(next_health_state_id INT);
    DECLARE @task_start_time DATETIME;
    DECLARE @task_elapsed_ms INT;
            
    -- get the "latest" set-number. We want all the health_state tables to 
    -- reflect the same point in time, and we achieve this by using a single 
    -- set_number column in each of the tables. At any point of time, we should 
    -- be using the entries from the table which correspond to the latest_health_state_id 
    -- value in the sysutility_ucp_processing_state_internal table
    UPDATE msdb.dbo.sysutility_ucp_processing_state_internal 
      SET next_health_state_id = next_health_state_id + 1
      OUTPUT INSERTED.next_health_state_id INTO @myTableVar;

    SELECT @new_set_number = next_health_state_id 
      FROM @myTableVar;
      
    -- Fetch the violations for health polices from latest policy evaluation 
    -- and cache them in the intermediate table. All the health state queries
    -- reference this table to optimize performance       
    SET @task_start_time = GETUTCDATE();
    EXEc dbo.sp_sysutility_ucp_get_policy_violations
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_get_policy_violations completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Identify filegroups that have a policy violation. (i.e.) all files in the filegroup
    -- should have violated the same policy. Logfiles are considered to belong to a
    -- fake filegroup with name=N''
    -- We will use this information in subsequent calls
    EXEC dbo.sp_sysutility_ucp_calculate_filegroups_with_policy_violations @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_filegroups_with_policy_violations completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Compute computer health state
    EXEC  sp_sysutility_ucp_calculate_computer_health @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_computer_health completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();

    -- Compute dac health state
    EXEC  msdb.dbo.sp_sysutility_ucp_calculate_dac_health @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_dac_health completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Compute dac dashboard health stats 
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_aggregated_dac_health @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_aggregated_dac_health completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Compute managed instance health state
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_mi_health @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_mi_health completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Compute managed instance dashboard health stats 
    EXEC msdb.dbo.sp_sysutility_ucp_calculate_aggregated_mi_health @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('sp_sysutility_ucp_calculate_aggregated_mi_health completed in %d ms', 0, 1, @task_elapsed_ms);
    SET @task_start_time = GETUTCDATE();
    
    -- Update the config table with the new set_number
    UPDATE msdb.dbo.sysutility_ucp_processing_state_internal
      SET latest_health_state_id = @new_set_number
    
    -- Delete the old sets
    SET @task_start_time = GETUTCDATE();
    DELETE FROM msdb.dbo.sysutility_ucp_aggregated_mi_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_mi_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_aggregated_dac_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_dac_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_computer_cpu_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_mi_volume_space_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_mi_database_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_mi_file_space_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_dac_file_space_health_internal WHERE set_number < @new_set_number
    DELETE FROM msdb.dbo.sysutility_ucp_filegroups_with_policy_violations_internal WHERE set_number < @new_set_number
    SET @task_elapsed_ms = DATEDIFF (ms, @task_start_time, GETUTCDATE());
    RAISERROR ('Deleted older sets in %d ms', 0, 1, @task_elapsed_ms);
    
END

GO
