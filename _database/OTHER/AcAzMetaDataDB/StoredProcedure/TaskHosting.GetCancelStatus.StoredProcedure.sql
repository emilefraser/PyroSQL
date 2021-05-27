SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TaskHosting].[GetCancelStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [TaskHosting].[GetCancelStatus] AS' 
END
GO

--Check whether a job is cancelled. When dss.job.IsCancelled is set, the job is cancelled.
--There are 2 possible states: cancelling and cancelled. A job is consider cancelling only
--when there's still live message exist for this job. Otherwise, it's in cancelled state.
--Add another parameter @CheckCancellingOnly so that we can use the same SP to check both
--Cancelling and Cancelled state without querying the DB twice.
ALTER PROCEDURE [TaskHosting].[GetCancelStatus]
  @JobId     uniqueidentifier,
  @CancelState  bit OUTPUT,
  @IsJobRunning  bit OUTPUT
AS
BEGIN
    IF @JobId IS NULL
    BEGIN
      RAISERROR('@JobId argument is wrong.', 16, 1)
      RETURN
    END

    SET NOCOUNT ON

    SELECT @CancelState = IsCancelled FROM TaskHosting.Job WHERE JobId = @JobId

    IF EXISTS (SELECT * FROM TaskHosting.MessageQueue WHERE JobId = @JobId)
        SET @IsJobRunning = 1
    ELSE
        SET @IsJobRunning = 0;

END

GO
