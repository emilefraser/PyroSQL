SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE [dbo].[sp_sqlagent_update_jobactivity_start_execution_date]
    @session_id               INT,
    @job_id                   UNIQUEIDENTIFIER,
    @is_system                TINYINT = 0,
    @begin_execution_date     INT,
    @begin_execution_time     INT
AS
BEGIN
    IF(@is_system = 1)
    BEGIN
		-- TODO:: Call job activity update spec proc
		RETURN
    END

   DECLARE @start_execution_date DATETIME
   SET @start_execution_date = [msdb].[dbo].[agent_datetime](@begin_execution_date, @begin_execution_time)

   UPDATE [msdb].[dbo].[sysjobactivity]
   SET start_execution_date = @start_execution_date
   WHERE session_id = @session_id
   AND job_id = @job_id
END

GO
