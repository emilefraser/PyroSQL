SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_queued_date]
    @session_id               INT,
    @job_id                   UNIQUEIDENTIFIER,
    @is_system             TINYINT = 0
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

    UPDATE [msdb].[dbo].[sysjobactivity]
    SET queued_date = DATEADD(ms, -DATEPART(ms, GETDATE()),  GETDATE())
    WHERE job_id = @job_id
    AND session_id = @session_id
END

GO
