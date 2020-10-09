SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_agent_delete_job
    @job_id                UNIQUEIDENTIFIER,
    @is_system             TINYINT = 0
AS
BEGIN
    DECLARE @retval INT

    IF(@is_system = 1)
    BEGIN
        -- Delete system job
        EXEC @retval = sys.sp_sqlagent_delete_job
            @job_id
    END
    ELSE
    BEGIN
        -- delete user job
        EXEC msdb.dbo.sp_delete_job @job_id = @job_id
        SELECT @retval = @@error
    END

    RETURN(@retval) -- 0 means success
END

GO
