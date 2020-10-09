SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE [dbo].[Get_sqlagent_job_status]
  -- Individual job parameters
  @job_id                     UNIQUEIDENTIFIER = NULL,  -- If provided will only return info about this job
                                                        --   Note: Only @job_id or @job_name needs to be provided
  @job_name                   sysname          = NULL,  -- If provided will only return info about this job
  @owner_login_name           sysname          = NULL   -- If provided will only return jobs for this owner
AS
BEGIN
  DECLARE @retval           INT
  DECLARE @job_owner_sid    VARBINARY(85)
  DECLARE @is_sysadmin      INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @job_name         = LTRIM(RTRIM(@job_name))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@job_name         = N'') SELECT @job_name = NULL


  -- Verify the job if supplied. This also checks if the caller has rights to view the job
  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = msdb..sp_verify_job_identifiers '@job_name',
                                                      '@job_id',
                                                       @job_name OUTPUT,
                                                       @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure

  END

  -- If the login name isn't given, set it to the job owner or the current caller
  IF(@owner_login_name IS NULL)
  BEGIN

    SET @owner_login_name = (SELECT SUSER_SNAME(sj.owner_sid) FROM msdb.dbo.sysjobs sj where sj.job_id = @job_id)

    SET @is_sysadmin = ISNULL(IS_SRVROLEMEMBER(N'sysadmin', @owner_login_name), 0)

  END
  ELSE
  BEGIN
    -- Check owner
    IF (SUSER_SID(@owner_login_name) IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@owner_login_name', @owner_login_name)
      RETURN(1) -- Failure
    END

    --only allow sysadmin types to specify the owner
    IF ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) <> 1) AND
        (ISNULL(IS_MEMBER(N'SQLAgentAdminRole'), 0) = 1) AND
        (SUSER_SNAME() <> @owner_login_name))
    BEGIN
      --TODO: RAISERROR(14525, -1, -1)
      RETURN(1) -- Failure
    END

    SET @is_sysadmin = 0
  END


  IF (@job_id IS NOT NULL)
  BEGIN
    -- Individual job...
    EXECUTE @retval =  master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @owner_login_name, @job_id
    IF (@retval <> 0)
      RETURN(1) -- Failure

  END
  ELSE
  BEGIN
    -- Set of jobs...
    EXECUTE @retval =  master.dbo.xp_sqlagent_enum_jobs @is_sysadmin, @owner_login_name
    IF (@retval <> 0)
      RETURN(1) -- Failure

  END

  RETURN(0) -- Success
END
GO
