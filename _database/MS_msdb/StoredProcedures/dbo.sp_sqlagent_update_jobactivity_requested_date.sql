SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_requested_date]
    @session_id               INT,
    @job_id                   UNIQUEIDENTIFIER,
    @is_system             TINYINT = 0,
    @run_requested_source_id  TINYINT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

    -- update sysjobactivity for user jobs
    UPDATE [msdb].[dbo].[sysjobactivity]
    SET run_requested_date = DATEADD(ms, -DATEPART(ms, GETDATE()),  GETDATE()),
        run_requested_source = CONVERT(SYSNAME, @run_requested_source_id),
        queued_date = NULL,
        start_execution_date = NULL,
        last_executed_step_id = NULL,
        last_executed_step_date = NULL,
        stop_execution_date = NULL,
        job_history_id = NULL,
        next_scheduled_run_date = NULL
    WHERE job_id = @job_id
    AND session_id = @session_id
END

GO
