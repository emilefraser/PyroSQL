SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_agent_log_job_history
    @job_id               UNIQUEIDENTIFIER,
    @is_system            TINYINT = 0,
    @step_id              INT,
    @sql_message_id       INT = 0,
    @sql_severity         INT = 0,
    @message              NVARCHAR(4000) = NULL,
    @run_status           INT, -- SQLAGENT_EXEC_X code
    @run_date             INT,
    @run_time             INT,
    @run_duration         INT,
    @operator_id_emailed  INT = 0,
    @operator_id_netsent  INT = 0,
    @operator_id_paged    INT = 0,
    @retries_attempted    INT,
    @server               sysname = NULL,
    @session_id           INT = 0
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
        EXEC sys.sp_sqlagent_log_job_history  @job_id = @job_id,
                @step_id = @step_id,
                @sql_message_id = @sql_message_id,
                @sql_severity = @sql_severity,
                @message = @message,
                @run_status = @run_status,
                @run_date = @run_date,
                @run_time = @run_time,
                @run_duration = @run_duration,
                @operator_id_emailed = @operator_id_emailed,
                @operator_id_paged = @operator_id_paged,
                @retries_attempted = @retries_attempted
    END
    ELSE
    BEGIN
        -- Update history for user jobs
        EXEC sp_sqlagent_log_jobhistory @job_id,
            @step_id,
            @sql_message_id,
            @sql_severity,
            @message,
            @run_status,
            @run_date,
            @run_time,
            @run_duration,
            @operator_id_emailed,
            @operator_id_netsent,
            @operator_id_paged,
            @retries_attempted,
            @server,
            @session_id
    END
END

GO
