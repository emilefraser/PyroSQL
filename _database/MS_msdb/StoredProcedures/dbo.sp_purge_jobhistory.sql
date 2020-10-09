SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_purge_jobhistory
  @job_name     sysname          = NULL,
  @job_id       UNIQUEIDENTIFIER = NULL,
  @oldest_date  DATETIME         = NULL
AS
BEGIN
  DECLARE @rows_affected INT
  DECLARE @total_rows    INT
  DECLARE @datepart      INT
  DECLARE @timepart      INT
  DECLARE @retval        INT
  DECLARE @job_owner_sid VARBINARY(85)

  SET NOCOUNT ON

  IF(@oldest_date IS NOT NULL)
  BEGIN
    SET @datepart = CONVERT(INT, CONVERT(VARCHAR, @oldest_date, 112))
    SET @timepart = (DATEPART(hh, @oldest_date) * 10000) + (DATEPART(mi, @oldest_date) * 100) + (DATEPART(ss, @oldest_date))
  END
  ELSE
  BEGIN
    SET @datepart = 99999999
    SET @timepart = 0
  END

  IF ((@job_name IS NOT NULL) OR (@job_id IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT,
                                                 @owner_sid = @job_owner_sid OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

    -- Check permissions beyond what's checked by the sysjobs_view
    -- SQLAgentReader role that can see all jobs but
    -- cannot purge history of jobs they do not own
    IF (@job_owner_sid <> SUSER_SID()                      -- does not own the job
       AND (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)       -- is not sysadmin
       AND (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) <> 1)) -- is not SQLAgentOperatorRole
    BEGIN
     RAISERROR(14392, -1, -1);
     RETURN(1) -- Failure
    END

    -- Delete the histories for this job
    DELETE FROM msdb.dbo.sysjobhistory
    WHERE (job_id = @job_id) AND
          ((run_date < @datepart) OR
           (run_date <= @datepart AND run_time < @timepart))
    SELECT @rows_affected = @@rowcount
  END
  ELSE
  BEGIN
    -- Only a sysadmin or SQLAgentOperatorRole can do this
   IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1)           -- is not sysadmin
       AND (ISNULL(IS_MEMBER(N'SQLAgentOperatorRole'), 0) <> 1)) -- is not SQLAgentOperatorRole
    BEGIN
      RAISERROR(14392, -1, -1)
      RETURN(1) -- Failure
    END

    IF(@oldest_date IS NOT NULL)
    BEGIN
        DELETE FROM msdb.dbo.sysjobhistory
        WHERE ((run_date < @datepart) OR
               (run_date <= @datepart AND run_time < @timepart))
    END
    ELSE
    BEGIN
        DELETE FROM msdb.dbo.sysjobhistory
    END

   SELECT @rows_affected = @@rowcount
  END

  RAISERROR(14226, 0, 1, @rows_affected)

  RETURN(0) -- Success
END

GO
