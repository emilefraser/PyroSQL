SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_mi_upload]
WITH EXECUTE AS OWNER
AS
BEGIN
   SET NOCOUNT ON;
   
   -- Check if the instance is enrolled
   IF ( 0 = (select [dbo].[fn_sysutility_ucp_get_instance_is_mi]()) )
   BEGIN
	  RAISERROR(37006, -1, -1)
     RETURN(1)
   END
   
   -- Check if Data Collector is enabled
   -- The following sproc will throw the correct error DC is disabled
   DECLARE @return_code INT;
   EXEC @return_code = [dbo].[sp_syscollector_verify_collector_state] @desired_state = 1
   IF (@return_code <> 0)
        RETURN (1)

   DECLARE @poll_delay_hh_mm_ss char(8)  = '00:00:10';
   DECLARE @start_delay_hh_mm_ss char(8)  = '00:00:10';
   
   DECLARE @start_time datetime2 = SYSUTCDATETIME();
   DECLARE @elapsed_time_ss INT
   
   DECLARE @collection_set_uid UNIQUEIDENTIFIER = N'ABA37A22-8039-48C6-8F8F-39BFE0A195DF';  
   DECLARE @collection_set_id INT = (SELECT collection_set_id FROM [dbo].[syscollector_collection_sets_internal]
                                    WHERE collection_set_uid = @collection_set_uid);
           
   DECLARE @is_upload_running INT;
   DECLARE @is_collection_running INT;

   -- If the collection set is running for some reason, wait for it
   -- to complete before instructing it to upload again.
   -- Assume that the collection is running before the loop starts
   SET @is_upload_running = 1;
   SET @is_collection_running = 1;
   
   -- Wait for the collection set to finish its previous execution        
   WHILE(1 = @is_collection_running OR 1 = @is_upload_running)
   BEGIN  
      -- Reset the while loop variables.  The sp will not update the values, if the collection
      -- is currently not running
      SET @is_upload_running = NULL;
      SET @is_collection_running = NULL;
      EXEC @return_code = [dbo].[sp_syscollector_get_collection_set_execution_status] 
            @collection_set_id = @collection_set_id,
            @is_collection_running = @is_collection_running OUTPUT,
            @is_upload_running = @is_upload_running OUTPUT
      IF (@@ERROR <> 0 OR @return_code <> 0) GOTO QuitWithError;

      -- Check to see if the collection is running before calling wait.
      -- It is more likely that it is not running, thus it is not optimal to wait.
      IF (1 = @is_collection_running OR 1 = @is_upload_running)
      BEGIN    
         SET @elapsed_time_ss = DATEDIFF(second, @start_time, SYSUTCDATETIME())
         RAISERROR ('Waiting for collection set to finish its previous run.  Total seconds spent waiting : %i', 0, 1, @elapsed_time_ss) WITH NOWAIT;
         WAITFOR DELAY @poll_delay_hh_mm_ss
      END

   END

   -- Grab the time before running the collection.  Use local time because later this value is used
   -- to find failures in the DC logs, which use local time.
   DECLARE @run_start_time datetime = SYSDATETIME();

   -- Start the collect and upload by invoking the run command
   RAISERROR ('Starting collection set.', 0, 1) WITH NOWAIT;
   EXEC @return_code = [msdb].[dbo].[sp_syscollector_run_collection_set] @collection_set_id = @collection_set_id
   IF (@@ERROR <> 0 OR @return_code <> 0) GOTO QuitWithError;    

   -- Allow the collection set to start
   RAISERROR ('Waiting for the collection set to kick off jobs.', 0, 1) WITH NOWAIT;
   WAITFOR DELAY @start_delay_hh_mm_ss
   
   -- Assume that the collection is running before the loop starts
   SET @is_upload_running = 1;
   SET @is_collection_running = 1;
   
   -- Wait for the collection set to finish it's previous execution        
   WHILE(1 = @is_collection_running OR 1 = @is_upload_running)
   BEGIN
      -- Reset the while loop variables.  The sp will not update the values, if the collection
      -- is currently not running
      SET @is_upload_running = NULL;
      SET @is_collection_running = NULL;
      
      -- Go ahead and wait on entry to the loop because it takes a 
      -- while for the collection set to finish collection
      SET @elapsed_time_ss = DATEDIFF(second, @start_time, SYSUTCDATETIME())
      RAISERROR ('Waiting for collection set to finish its previous run.  Total seconds spent waiting : %i', 0, 1, @elapsed_time_ss) WITH NOWAIT;
      WAITFOR DELAY @poll_delay_hh_mm_ss

      EXEC @return_code = [dbo].[sp_syscollector_get_collection_set_execution_status] 
            @collection_set_id = @collection_set_id,
            @is_collection_running = @is_collection_running OUTPUT,
            @is_upload_running = @is_upload_running OUTPUT
      IF (@@ERROR <> 0 OR @return_code <> 0) GOTO QuitWithError;
   END
   
   DECLARE @status_failure smallint = 2
   DECLARE @last_reported_status smallint = NULL
   
   -- Check if the collect/upload failed anytime after the call to run
   -- This is not precise in finding our exact run, but most of the time it will find our run
   -- What we really need to know is if the collect/upload failed
   -- There is a possibility that there are false positives (report failure, when our call to run passed)
   -- However, we are willing to risk it for simplicity.
   SELECT TOP 1 @last_reported_status = status 
   FROM msdb.dbo.syscollector_execution_log_internal 
      WHERE collection_set_id = @collection_set_id 
      AND parent_log_id IS NULL
      AND finish_time IS NOT NULL   
      AND start_time >= @run_start_time
      ORDER BY finish_time DESC

    IF (@last_reported_status = @status_failure)
    BEGIN
        RAISERROR(37007, -1, -1)
        RETURN(1) -- Failure
    END

   Return(0);
    
   QuitWithError:
      RAISERROR ('An error occurred during execution.', 0, 1) WITH NOWAIT;
      RETURN (1);
END

GO
