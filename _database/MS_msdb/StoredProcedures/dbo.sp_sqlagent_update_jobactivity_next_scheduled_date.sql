SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_next_scheduled_date]
    @session_id            INT,
    @job_id                UNIQUEIDENTIFIER,
	@is_system             TINYINT = 0,
    @last_run_date         INT,
    @last_run_time         INT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

   DECLARE @next_scheduled_run_date DATETIME
   SET @next_scheduled_run_date = NULL

   -- If last rundate and last runtime is not null then convert date, time to datetime
   IF (@last_run_date IS NOT NULL AND @last_run_time IS NOT NULL)
   BEGIN
        SET @next_scheduled_run_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)
   END

   UPDATE [msdb].[dbo].[sysjobactivity]
   SET next_scheduled_run_date = @next_scheduled_run_date
   WHERE session_id = @session_id
   AND job_id = @job_id
END

GO
