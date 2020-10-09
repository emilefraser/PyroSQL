SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[sp_sysutility_mi_collect_dac_execution_statistics_internal]
AS
BEGIN
   DECLARE @current_collection_time datetimeoffset = SYSDATETIMEOFFSET();
   DECLARE @previous_collection_time datetimeoffset;
  
   -- At this point the session stats table should contain only rows from the prior collection time (or no 
   -- rows, in which case @previous_collection_time will be set to NULL). Retrieve the prior collection time. 
   SELECT TOP 1 @previous_collection_time = collection_time 
   FROM dbo.sysutility_mi_session_statistics_internal
   ORDER BY collection_time DESC; 

   -- Get a list of the DACs deployed on this instance.  In the sysdac_instances view, some of these values 
   -- are unindexed computed columns.  Store them in a temp table so that we get indexed retrieval by dbid 
   -- or db/instance name and stats on the columns we'll use as join columns. 
   CREATE TABLE #dacs (
      dac_instance_name sysname PRIMARY KEY, 
      database_name sysname UNIQUE, 
      database_id int UNIQUE, 
      date_created datetime, 
      [description] nvarchar(4000));
      
   INSERT INTO #dacs 
   SELECT DISTINCT 
      instance_name, 
      database_name, 
      DB_ID(database_name), 
      date_created, 
      [description]
   FROM dbo.sysdac_instances
   -- Filter out "orphaned" DACs that have had their database deleted or renamed
   WHERE DB_ID(database_name) IS NOT NULL;

   -- Step 1: Capture execution stats for all current sessions in DAC databases. Now this table should 
   -- hold two snapshots: one that we just inserted (referred to as the "current" data from here on), and 
   -- the immediately prior snapshot of the same data from ~15 seconds ago ("previous").  Note that we 
   -- include a dummy row with a fake spid number for any DACs that don't have any active sessions.  This 
   -- is because of a downstream requirement that we return a row for all DACs, even if there are no stats 
   -- to report for the DAC.  
   INSERT INTO dbo.sysutility_mi_session_statistics_internal 
      (collection_time, session_id, dac_instance_name, database_name, login_time, cumulative_cpu_ms)
   SELECT 
      @current_collection_time, 
      ISNULL (sp.spid, -10) AS session_id, 
      #dacs.dac_instance_name, 
      #dacs.database_name, 
      ISNULL (sp.login_time, GETDATE()) AS login_time, 
      ISNULL (SUM(sp.cpu), 0) AS cumulative_cpu_ms
   FROM #dacs 
   LEFT OUTER JOIN sys.sysprocesses AS sp ON #dacs.database_id = sp.[dbid]
   GROUP BY ISNULL (sp.spid, -10), #dacs.dac_instance_name, #dacs.database_name, ISNULL (sp.login_time, GETDATE()); 

   -- Step 2: If this is the first execution, set @prev_collection_time to @cur_collection_time. 
   -- This has the effect of generating stats that indicate no work done for all DACs.  This is 
   -- the best we can do on the first execution because we need to snapshots in order to calculate 
   -- correct resource consumption over a time interval.  We can't just return here, because we 
   -- need at least a "stub" row for each DAC, so they all DACs will appear in the UI if a DC 
   -- upload runs before our next collection time. 
   IF (@previous_collection_time IS NULL)
   BEGIN
      SET @previous_collection_time = @current_collection_time;
   END;

   -- Step 3: Determine the amount of new CPU time used by each DAC in the just-completed ~15 second interval 
   -- (this defines a CTE that is used in the following step). 
   WITH interval_dac_statistics AS (
      SELECT 
         #dacs.dac_instance_name, 
         -- Add up the approximate CPU time used by each session since the last execution of this proc. 
         -- The [current CPU] - [previous CPU] calculation for a session will return NULL if 
         -- [previous CPU] is NULL ([current CPU] should never be NULL).  Previous CPU might be 
         -- NULL if the session is new.  Previous CPU could also be NULL if an existing session 
         -- changed database context.  In either case, we will not charge any of the session's 
         -- CPU time to the database for this interval.  We will start charging any new session 
         -- CPU time to the session's current database on the next execution of this procedure, 
         -- assuming that the session doesn't change database context between now and then.  
         SUM (ISNULL (cur.cumulative_cpu_ms - prev.cumulative_cpu_ms, 0)) AS interval_cpu_time_ms, 
         #dacs.database_name, 
         #dacs.database_id, 
         #dacs.date_created, 
         #dacs.[description]
      FROM #dacs 
      LEFT OUTER JOIN dbo.sysutility_mi_session_statistics_internal AS cur   -- current snapshot, "right" side of time interval
         ON #dacs.dac_instance_name = cur.dac_instance_name AND cur.collection_time = @current_collection_time
      LEFT OUTER JOIN dbo.sysutility_mi_session_statistics_internal AS prev  -- previous snapshot, "left" side of time interval
         ON cur.dac_instance_name = prev.dac_instance_name AND prev.collection_time = @previous_collection_time 
            AND cur.session_id = prev.session_id AND cur.login_time = prev.login_time 
      GROUP BY #dacs.dac_instance_name, #dacs.database_name, #dacs.database_id, #dacs.date_created, #dacs.[description]
   )
   
   -- Step 4: Do an "upsert" to the staging table.  If the DAC is already represented in this table, we will 
   -- add our interval CPU time to that row's [lifetime_cpu_time_ms] value. If the DAC does not yet exist 
   -- in the staging table, we will insert a new row.  
   -- 
   -- A note about overflow risk for the [lifetime_cpu_time_ms] column (bigint).  A DAC that used 100% of 
   -- every CPU on a 500 processor machine 24 hours a day could run for more than half a million years without 
   -- overflowing this column.  
   MERGE [dbo].[sysutility_mi_dac_execution_statistics_internal] AS [target]
   USING interval_dac_statistics AS [source] 
      ON [source].dac_instance_name = [target].dac_instance_name 
         -- Filter out "orphaned" DACs that have had their database deleted or renamed
         AND DB_ID([target].database_name) IS NOT NULL 
   
   WHEN MATCHED THEN UPDATE 
      SET [target].lifetime_cpu_time_ms = ISNULL([target].lifetime_cpu_time_ms, 0) + [source].interval_cpu_time_ms, 
         [target].last_collection_time = @current_collection_time, 
         [target].first_collection_time = ISNULL ([target].first_collection_time, @previous_collection_time), 
         [target].database_name = [source].database_name, 
         [target].database_id = [source].database_id, 
         [target].date_created = [source].date_created, 
         [target].[description] = [source].[description] 
   
   WHEN NOT MATCHED BY TARGET THEN INSERT (  -- new DAC
      dac_instance_name, 
      first_collection_time, 
      last_collection_time, 
      last_upload_time, 
      lifetime_cpu_time_ms, 
      cpu_time_ms_at_last_upload, 
      database_name, 
      database_id, 
      date_created, 
      [description])
      VALUES (
         [source].dac_instance_name, 
         @previous_collection_time, 
         @current_collection_time, 
         @previous_collection_time, 
         [source].interval_cpu_time_ms, 
         0, 
         [source].database_name, 
         [source].database_id, 
         [source].date_created, 
         [source].[description])
   
   WHEN NOT MATCHED BY SOURCE THEN DELETE;   -- deleted or orphaned DAC

   -- Step 5: Delete the session stats from the previous collection time as we no longer need them (but keep the 
   -- current stats we just collected in Step 1; at the next collection time these will be the "previous" 
   -- stats that we'll use to calculate the stats for the next interval). 
   DELETE FROM dbo.sysutility_mi_session_statistics_internal WHERE collection_time != @current_collection_time;
END;

GO
