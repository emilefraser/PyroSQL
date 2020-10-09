SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_verify_job_identifiers
  @name_of_name_parameter  VARCHAR(60),             -- Eg. '@job_name'
  @name_of_id_parameter    VARCHAR(60),             -- Eg. '@job_id'
  @job_name                sysname          OUTPUT, -- Eg. 'My Job'
  @job_id                  UNIQUEIDENTIFIER OUTPUT,
  @sqlagent_starting_test  VARCHAR(7) = 'TEST',      -- By default we DO want to test if SQLServerAgent is running (caller should specify 'NO_TEST' if not desired)
  @owner_sid                VARBINARY(85) = NULL OUTPUT
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @job_id_as_char VARCHAR(36)

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @name_of_name_parameter = LTRIM(RTRIM(@name_of_name_parameter))
  SELECT @name_of_id_parameter   = LTRIM(RTRIM(@name_of_id_parameter))
  SELECT @job_name               = LTRIM(RTRIM(@job_name))

  IF (@job_name = N'') SELECT @job_name = NULL

  IF ((@job_name IS NULL)     AND (@job_id IS NULL)) OR
     ((@job_name IS NOT NULL) AND (@job_id IS NOT NULL))
  BEGIN
    RAISERROR(14294, -1, -1, @name_of_id_parameter, @name_of_name_parameter)
    RETURN(1) -- Failure
  END

  -- Check job id
  IF (@job_id IS NOT NULL)
  BEGIN
    SELECT @job_name = name,
           @owner_sid = owner_sid
    FROM msdb.dbo.sysjobs_view
    WHERE (job_id = @job_id)

    -- the view would take care of all the permissions issues.
    IF (@job_name IS NULL)
    BEGIN
      SELECT @job_id_as_char = CONVERT(VARCHAR(36), @job_id)
      RAISERROR(14262, -1, -1, '@job_id', @job_id_as_char)
      RETURN(1) -- Failure
    END
  END
  ELSE
  -- Check job name
  IF (@job_name IS NOT NULL)
  BEGIN
    -- Check if the job name is ambiguous
    IF ((SELECT COUNT(*)
         FROM msdb.dbo.sysjobs_view
         WHERE (name = @job_name)) > 1)
    BEGIN
      RAISERROR(14293, -1, -1, @job_name, @name_of_id_parameter, @name_of_name_parameter)
      RETURN(1) -- Failure
    END

    -- The name is not ambiguous, so get the corresponding job_id (if the job exists)
    SELECT @job_id = job_id,
           @owner_sid = owner_sid
    FROM msdb.dbo.sysjobs_view
    WHERE (name = @job_name)

    -- the view would take care of all the permissions issues.
    IF (@job_id IS NULL)
    BEGIN
      RAISERROR(14262, -1, -1, '@job_name', @job_name)
      RETURN(1) -- Failure
    END
  END

  IF (@sqlagent_starting_test = 'TEST')
  BEGIN
    -- Finally, check if SQLServerAgent is in the process of starting and if so prevent the
    -- calling SP from running
    EXECUTE @retval = msdb.dbo.sp_is_sqlagent_starting
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  RETURN(0) -- Success
END

GO
