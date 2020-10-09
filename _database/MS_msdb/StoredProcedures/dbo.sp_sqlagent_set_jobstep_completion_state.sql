SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_set_jobstep_completion_state]
    @job_id                UNIQUEIDENTIFIER,
    @step_id               INT,
    @last_run_outcome      INT,
    @last_run_duration     INT,
    @last_run_retries      INT,
    @last_run_date         INT,
    @last_run_time         INT,
    @session_id            INT
AS
BEGIN
    -- Update job step completion state in sysjobsteps as well as sysjobactivity
    UPDATE [msdb].[dbo].[sysjobsteps]
    SET last_run_outcome      = @last_run_outcome,
        last_run_duration     = @last_run_duration,
        last_run_retries      = @last_run_retries,
        last_run_date         = @last_run_date,
        last_run_time         = @last_run_time
    WHERE job_id   = @job_id
    AND   step_id  = @step_id

    DECLARE @last_executed_step_date DATETIME
    SET @last_executed_step_date = [msdb].[dbo].[agent_datetime](@last_run_date, @last_run_time)

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET last_executed_step_date = @last_executed_step_date,
        last_executed_step_id   = @step_id
    WHERE job_id     = @job_id
    AND   session_id = @session_id
END

GO
