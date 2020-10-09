SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE sp_agent_write_sysjobstep_log
    @job_id    UNIQUEIDENTIFIER,
    @is_system TINYINT = 0,
    @step_id   INT,
    @log_text  NVARCHAR(MAX),
    @append_to_last INT = 0
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
        EXEC sys.sp_sqlagent_write_jobstep_log @job_id = @job_id,
            @step_id = @step_id,
            @log_text = @log_text
    RETURN
    END
    ELSE
    BEGIN
        EXEC sp_write_sysjobstep_log @job_id = @job_id,
            @step_id = @step_id,
            @log_text = @log_text,
            @append_to_last = @append_to_last
    END
END

GO
