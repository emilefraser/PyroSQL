SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_mi_get_dac_execution_statistics_internal]
AS
BEGIN
   SET NOCOUNT ON;   -- Required for SSIS to retrieve the proc's output rowset 
   DECLARE @logical_processor_count int;
   SELECT @logical_processor_count = cpu_count FROM sys.dm_os_sys_info;
   
   -- Get the shared "batch time" that will be a part of all data collection query rowsets.  On the UCP, this 
   -- will be used to tie together all of the data from one execution of the MI data collection job. 
   
   -- Check for the existance of the temp table.  If it is there, then the Utility is
   -- set up correctly.  If it is not there, do not fail the upload.  This handles the
   -- case when a user might run the collection set out-of-band from the Utility.
   -- The data may not be staged, but no sporratic errors should occur
   DECLARE @current_batch_time datetimeoffset(7) = SYSDATETIMEOFFSET();
   IF OBJECT_ID ('[tempdb].[dbo].[sysutility_batch_time_internal]') IS NOT NULL
   BEGIN
      SELECT @current_batch_time = latest_batch_time FROM tempdb.dbo.sysutility_batch_time_internal;
   END

   -- Temp storage for the DAC execution statistics for this data collection interval (typically, a 15 minute window). 
   -- This and the following table variable would be better as a temp table (b/c of the potentially large number 
   -- of rows), but this proc is run by DC with SET FMTONLY ON to get the output rowset schema.  That means no 
   -- temp tables.  
   DECLARE @upload_interval_dac_stats TABLE (
      dac_instance_name sysname PRIMARY KEY, 
      lifetime_cpu_time_ms bigint NULL,   -- amount of CPU time consumed since we started tracking this DAC
      interval_cpu_time_ms bigint NULL,   -- amount of CPU time used by the DAC in this ~15 min upload interval
      interval_start_time datetimeoffset NULL, 
      interval_end_time datetimeoffset NULL
   );
   
   -- We use an update with an OUTPUT clause to atomically update the staging table and retrieve data from it.  
   -- The use of the "inserted"/"deleted" pseudo-tables in this query ensures that we don't lose any data if the 
   -- collection job happens to be running at the same time. 
   UPDATE dbo.sysutility_mi_dac_execution_statistics_internal
   SET last_upload_time = SYSDATETIMEOFFSET(), 
       cpu_time_ms_at_last_upload = lifetime_cpu_time_ms 
   OUTPUT 
      inserted.dac_instance_name, 
      inserted.lifetime_cpu_time_ms, 
      -- Calculate the amount of CPU time consumed by this DAC since the last time we did an upload. 
      (inserted.cpu_time_ms_at_last_upload - ISNULL (deleted.cpu_time_ms_at_last_upload, 0)) AS interval_cpu_time_ms, 
      deleted.last_upload_time AS interval_start_time, 
      inserted.last_upload_time AS interval_end_time
   INTO @upload_interval_dac_stats;
   
   -- Return the data to the collection set
   SELECT 
      CONVERT (sysname, SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS physical_server_name, 
      CONVERT (sysname, SERVERPROPERTY('ServerName')) AS server_instance_name, 
      CONVERT (sysname, dacs.database_name) AS dac_db, 
      dacs.date_created AS dac_deploy_date, 
      dacs.[description] AS dac_description, 
      dacs.dac_instance_name AS dac_name, 
      dac_stats.interval_start_time, 
      dac_stats.interval_end_time, 
      dac_stats.interval_cpu_time_ms, 
      CONVERT (real, CASE 
         WHEN dac_stats.interval_cpu_time_ms IS NOT NULL 
            AND DATEDIFF (second, dac_stats.interval_start_time, dac_stats.interval_end_time) > 0
            -- % CPU calculation is: [avg seconds of cpu time used per processor] / [interval duration in sec]
            -- The percentage value is returned as an int (e.g. 76 for 76%, not 0.76)
            THEN 100 * (dac_stats.interval_cpu_time_ms / @logical_processor_count) / 1000 / 
               DATEDIFF (second, dac_stats.interval_start_time, dac_stats.interval_end_time)
         ELSE 0
      END) AS interval_cpu_pct, 
      dac_stats.lifetime_cpu_time_ms, 
      @current_batch_time AS batch_time
   FROM dbo.sysutility_mi_dac_execution_statistics_internal AS dacs 
   LEFT OUTER JOIN @upload_interval_dac_stats AS dac_stats ON dacs.dac_instance_name = dac_stats.dac_instance_name;
END;

GO
