SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_agent_start_job
  @job_id      UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @retval INT

    EXEC @retval = sys.sp_sqlagent_start_job @job_id

    RETURN(@retval) -- 0 means success
END

GO
