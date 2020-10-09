SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_agent_add_jobstep
    @job_id                UNIQUEIDENTIFIER = NULL,   -- Must provide either this or job_name
    @job_name              SYSNAME          = NULL,   -- Must provide either this or job_id
    @step_id               INT              = NULL,
    @step_name             SYSNAME,
    @subsystem             NVARCHAR(40)     = N'TSQL',
    @command               NVARCHAR(max)    = NULL,
    @additional_parameters NVARCHAR(max)    = NULL,
    @cmdexec_success_code  INT              = 0,
    @on_success_action     TINYINT          = 1,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
    @on_success_step_id    INT              = 0,
    @on_fail_action        TINYINT          = 2,      -- 1 = Quit With Success, 2 = Quit With Failure, 3 = Goto Next Step, 4 = Goto Step
    @on_fail_step_id       INT              = 0,
    @server                SYSNAME          = NULL,
    @database_name         SYSNAME          = NULL,
    @database_user_name    SYSNAME          = NULL,
    @retry_attempts        INT              = 0,
    @retry_interval        INT              = 0,
    @os_run_priority       INT              = 0,
    @output_file_name      NVARCHAR(200)    = NULL,
    @flags                 INT              = 128,     -- 128  - System jobstep flag
    @step_uid UNIQUEIDENTIFIER              = NULL OUTPUT
AS
BEGIN
    DECLARE @retval INT

    EXEC @retval = sys.sp_sqlagent_add_jobstep   @job_id = @job_id,
        @job_name = @job_name,
        @step_id = @step_id,
        @step_name = @step_name,
        @subsystem = @subsystem,
        @command = @command,
        @flags = @flags,
        @additional_parameters = @additional_parameters,
        @cmdexec_success_code = @cmdexec_success_code,
        @on_success_action = @on_success_action,
        @on_success_step_id = @on_success_step_id,
        @on_fail_action = @on_fail_action,
        @on_fail_step_id = @on_fail_step_id,
        @server = @server,
        @database_name = @database_name,
        @database_user_name = @database_user_name,
        @retry_attempts = @retry_attempts,
        @retry_interval = @retry_interval,
        @os_run_priority = @os_run_priority,
        @output_file_name = @output_file_name,
        @step_uid = @step_uid OUTPUT

    RETURN(@retval) -- 0 means success
END

GO
