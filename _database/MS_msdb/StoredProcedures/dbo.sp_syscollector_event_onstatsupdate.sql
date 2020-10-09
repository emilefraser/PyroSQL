SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_syscollector_event_onstatsupdate]
    @log_id bigint,
    @task_name nvarchar(128),
    @row_count_in int = NULL,
    @row_count_out int = NULL,
    @row_count_error int = NULL,
    @execution_time_ms int = NULL
AS
BEGIN
    SET NOCOUNT ON

    -- Security check (role membership)
    IF (NOT (ISNULL(IS_MEMBER(N'dc_proxy'), 0) = 1) AND NOT (ISNULL(IS_MEMBER(N'db_owner'), 0) = 1))
    BEGIN
        RAISERROR(14677, -1, -1, 'dc_proxy')
        RETURN(1) -- Failure
    END

    -- Check the log_id
    DECLARE @retVal INT
    EXEC @retVal = dbo.sp_syscollector_verify_event_log_id @log_id
    IF (@retVal <> 0)
        RETURN (@retVal)
    
    -- Check task name
    IF (@task_name IS NOT NULL)
    BEGIN
        SET @task_name = NULLIF(LTRIM(RTRIM(@task_name)), N'')
    END
    IF (@task_name IS NULL)
    BEGIN
        RAISERROR(14606, -1, -1, '@task_name')
        RETURN (1)
    END
    
    -- Insert the log entry
    INSERT INTO dbo.syscollector_execution_stats_internal (
        log_id,
        task_name,
        execution_row_count_in,
        execution_row_count_out,
        execution_row_count_errors,
        execution_time_ms,
        log_time
    ) VALUES (
        @log_id,
        @task_name,
        @row_count_in,
        @row_count_out,
        @row_count_error,
        NULLIF(@execution_time_ms, 0),
        GETDATE()
    )

    RETURN (0)
END

GO
