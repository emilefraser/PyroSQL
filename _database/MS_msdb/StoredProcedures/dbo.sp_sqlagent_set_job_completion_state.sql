SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_set_job_completion_state]
    @job_id               UNIQUEIDENTIFIER,
    @last_run_outcome     TINYINT,
    @last_outcome_message NVARCHAR(4000),
    @last_run_date        INT,
    @last_run_time        INT,
    @last_run_duration    INT
AS
BEGIN
    -- Update last run date, time for specific job_id in local server
    UPDATE msdb.dbo.sysjobservers
    SET last_run_outcome =  @last_run_outcome,
        last_outcome_message = @last_outcome_message,
        last_run_date = @last_run_date,
        last_run_time = @last_run_time,
        last_run_duration = @last_run_duration
    WHERE job_id  = @job_id
    AND server_id = 0
END

GO
