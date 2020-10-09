SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_create_jobactivity]
    @session_id            INT,
    @job_id                UNIQUEIDENTIFIER,
	@is_system             TINYINT = 0
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
        -- TODO:: Call job activity update spec proc
    RETURN
    END

    IF(@job_id IS NULL)
    BEGIN
        -- On SQL Agent startup, session id along with all jobs are populated
        INSERT [msdb].[dbo].[sysjobactivity]
        (session_id, job_id)
        SELECT @session_id, job_id
        FROM [msdb].[dbo].[sysjobs]
    END
    ELSE
    BEGIN
        -- whenever a new job was created later & started, only that specific job_id is populated in
        -- sysjobactivity table
        INSERT [msdb].[dbo].[sysjobactivity]
        (session_id, job_id)
        VALUES(
            @session_id,
            @job_id
        )
    END
END

GO
