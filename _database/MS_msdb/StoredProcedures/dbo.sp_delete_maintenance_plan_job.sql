SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_delete_maintenance_plan_job
  @plan_id uniqueidentifier,
  @job_id  uniqueidentifier
AS
BEGIN
  /*check if the (plan_id, job_id) exists*/
  IF (NOT EXISTS(SELECT *
                 FROM sysdbmaintplan_jobs
                 WHERE @plan_id=plan_id AND @job_id=job_id))
  BEGIN
    DECLARE @syserr VARCHAR(300)
    SELECT @syserr=CONVERT(VARCHAR(100),@plan_id)+' + '+CONVERT(VARCHAR(100),@job_id)
    RAISERROR(14262,-1,-1,'@plan_id+@job_id',@syserr)
    RETURN(1)
  END
  DELETE FROM msdb.dbo.sysdbmaintplan_jobs
  WHERE plan_id=@plan_id AND job_id=@job_id
END

GO
