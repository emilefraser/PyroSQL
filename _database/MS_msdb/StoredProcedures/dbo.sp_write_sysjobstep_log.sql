SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_write_sysjobstep_log
  @job_id    UNIQUEIDENTIFIER,
  @step_id   INT,
  @log_text  NVARCHAR(MAX),
  @append_to_last INT = 0
AS
BEGIN
  DECLARE @step_uid UNIQUEIDENTIFIER
  DECLARE @log_already_exists int
  SET @log_already_exists = 0

  SET @step_uid = ( SELECT step_uid FROM  msdb.dbo.sysjobsteps
      WHERE (job_id = @job_id)
        AND (step_id = @step_id) )


  IF(EXISTS(SELECT * FROM msdb.dbo.sysjobstepslogs
                      WHERE step_uid = @step_uid ))
  BEGIN
     SET @log_already_exists = 1
  END

  --Need create log if "overwrite is selected or log does not exists.
  IF (@append_to_last = 0) OR (@log_already_exists = 0)
  BEGIN
     -- flag is overwrite

     --if overwrite and log exists, delete it
     IF (@append_to_last = 0 AND @log_already_exists = 1)
     BEGIN
        -- remove previous logs entries
        EXEC sp_delete_jobsteplog @job_id, NULL, @step_id, NULL
     END

     INSERT INTO msdb.dbo.sysjobstepslogs
      (
         log,
         log_size,
         step_uid
      )
      VALUES
      (
         @log_text,
         DATALENGTH(@log_text),
         @step_uid
      )
  END
  ELSE
  BEGIN
     DECLARE @log_id   INT
     --Selecting TOP is just a safety net - there is only one log entry row per step.
     SET @log_id = ( SELECT TOP 1 log_id FROM msdb.dbo.sysjobstepslogs
         WHERE (step_uid = @step_uid)
           ORDER BY log_id DESC )

      -- Append @log_text to the existing log record. Note that if this
      -- action would make the value of the log column longer than
      -- nvarchar(max), then the engine will raise error 599.
      UPDATE msdb.dbo.sysjobstepslogs
        SET
             log .WRITE(@log_text,NULL,0),
             log_size = DATALENGTH(log) + DATALENGTH(@log_text) ,
             date_modified = getdate()
      WHERE log_id = @log_id
  END

  RETURN(@@error) -- 0 means success

END

GO
