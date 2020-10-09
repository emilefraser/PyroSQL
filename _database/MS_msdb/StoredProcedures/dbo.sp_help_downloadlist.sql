SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_help_downloadlist
  @job_id          UNIQUEIDENTIFIER = NULL, -- If provided must NOT also provide job_name
  @job_name        sysname          = NULL, -- If provided must NOT also provide job_id
  @operation       VARCHAR(64)      = NULL,
  @object_type     VARCHAR(64)      = NULL, -- Only 'JOB' or 'SERVER' are valid in 7.0
  @object_name     sysname          = NULL,
  @target_server   sysname         = NULL,
  @has_error       TINYINT          = NULL, -- NULL or 1
  @status          TINYINT          = NULL,
  @date_posted     DATETIME         = NULL  -- Include all entries made on OR AFTER this date
AS
BEGIN
  DECLARE @retval         INT
  DECLARE @operation_code INT
  DECLARE @object_type_id TINYINT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @operation     = LTRIM(RTRIM(@operation))
  SELECT @object_type   = LTRIM(RTRIM(@object_type))
  SELECT @object_name   = LTRIM(RTRIM(@object_name))
  SELECT @target_server = UPPER(LTRIM(RTRIM(@target_server)))

  -- Turn [nullable] empty string parameters into NULLs
  IF (@operation     = '') SELECT @operation = NULL
  IF (@object_type   = '') SELECT @object_type = NULL
  IF (@object_name   = N'') SELECT @object_name = NULL
  IF (@target_server = N'') SELECT @target_server = NULL

  IF ((@job_id IS NOT NULL) OR (@job_name IS NOT NULL))
  BEGIN
    EXECUTE @retval = sp_verify_job_identifiers '@job_name',
                                                '@job_id',
                                                 @job_name OUTPUT,
                                                 @job_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

  -- Check operation
  IF (@operation IS NOT NULL)
  BEGIN
    SELECT @operation = UPPER(@operation collate SQL_Latin1_General_CP1_CS_AS)
    SELECT @operation_code = CASE @operation
                               WHEN 'INSERT'    THEN 1
                               WHEN 'UPDATE'    THEN 2
                               WHEN 'DELETE'    THEN 3
                               WHEN 'START'     THEN 4
                               WHEN 'STOP'      THEN 5
                               WHEN 'RE-ENLIST' THEN 6
                               WHEN 'DEFECT'    THEN 7
                               WHEN 'SYNC-TIME' THEN 8
                               WHEN 'SET-POLL'  THEN 9
                               ELSE 0
                             END
    IF (@operation_code = 0)
    BEGIN
      RAISERROR(14266, -1, -1, '@operation_code', 'INSERT, UPDATE, DELETE, START, STOP, RE-ENLIST, DEFECT, SYNC-TIME, SET-POLL')
      RETURN(1) -- Failure
    END
  END

  -- Check object type (in 7.0 only 'JOB' and 'SERVER' are valid)
  IF (@object_type IS NOT NULL)
  BEGIN
    SELECT @object_type = UPPER(@object_type collate SQL_Latin1_General_CP1_CS_AS)
    IF ((@object_type <> 'JOB') AND (@object_type <> 'SERVER'))
    BEGIN
      RAISERROR(14266, -1, -1, '@object_type', 'JOB, SERVER')
      RETURN(1) -- Failure
    END
    ELSE
      SELECT @object_type_id = CASE @object_type
                                 WHEN 'JOB'    THEN 1
                                 WHEN 'SERVER' THEN 2
                                 ELSE 0
                               END
  END

  -- If object-type is supplied then object-name must also be supplied
  IF ((@object_type IS NOT NULL) AND (@object_name IS NULL)) OR
     ((@object_type IS NULL)     AND (@object_name IS NOT NULL))
  BEGIN
    RAISERROR(14272, -1, -1)
    RETURN(1) -- Failure
  END

  -- Check target server
  IF (@target_server IS NOT NULL) AND NOT EXISTS (SELECT *
                                                  FROM msdb.dbo.systargetservers
                                                  WHERE UPPER(server_name) = @target_server)
  BEGIN
    RAISERROR(14262, -1, -1, '@target_server', @target_server)
    RETURN(1) -- Failure
  END

  -- Check has-error
  IF (@has_error IS NOT NULL) AND (@has_error <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@has_error', '1, NULL')
    RETURN(1) -- Failure
  END

  -- Check status
  IF (@status IS NOT NULL) AND (@status <> 0) AND (@status <> 1)
  BEGIN
    RAISERROR(14266, -1, -1, '@status', '0, 1')
    RETURN(1) -- Failure
  END

  -- Return the result set
  SELECT sdl.instance_id,
         sdl.source_server,
        'operation_code' = CASE sdl.operation_code
                             WHEN 1 THEN '1 (INSERT)'
                             WHEN 2 THEN '2 (UPDATE)'
                             WHEN 3 THEN '3 (DELETE)'
                             WHEN 4 THEN '4 (START)'
                             WHEN 5 THEN '5 (STOP)'
                             WHEN 6 THEN '6 (RE-ENLIST)'
                             WHEN 7 THEN '7 (DEFECT)'
                             WHEN 8 THEN '8 (SYNC-TIME)'
                             WHEN 9 THEN '9 (SET-POLL)'
                             ELSE CONVERT(VARCHAR, sdl.operation_code) + ' ' + FORMATMESSAGE(14205)
                           END,
        'object_name' = ISNULL(sjv.name, CASE
                                           WHEN (sdl.operation_code >= 1) AND (sdl.operation_code <= 5) AND (sdl.object_id = CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN FORMATMESSAGE(14212) -- '(all jobs)'
                                           WHEN (sdl.operation_code  = 3) AND (sdl.object_id <> CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN sdl.deleted_object_name -- Special case handling for a deleted job
                                           WHEN (sdl.operation_code >= 1) AND (sdl.operation_code <= 5) AND (sdl.object_id <> CONVERT(UNIQUEIDENTIFIER, 0x00)) THEN FORMATMESSAGE(14580) -- 'job' (safety belt: should never appear)
                                           WHEN (sdl.operation_code >= 6) AND (sdl.operation_code <= 9) THEN sdl.target_server
                                           ELSE FORMATMESSAGE(14205)
                                         END),
        'object_id' = ISNULL(sjv.job_id, CASE sdl.object_id
                                           WHEN CONVERT(UNIQUEIDENTIFIER, 0x00) THEN CONVERT(UNIQUEIDENTIFIER, 0x00)
                                           ELSE sdl.object_id
                                         END),
         sdl.target_server,
         sdl.error_message,
         sdl.date_posted,
         sdl.date_downloaded,
         sdl.status
  FROM msdb.dbo.sysdownloadlist sdl LEFT OUTER JOIN
       msdb.dbo.sysjobs_view    sjv ON (sdl.object_id = sjv.job_id)
  WHERE ((@operation_code IS NULL) OR (operation_code = @operation_code))
    AND ((@object_type_id IS NULL) OR (object_type = @object_type_id))
    AND ((@job_id         IS NULL) OR (object_id = @job_id))
    AND ((@target_server  IS NULL) OR (target_server = @target_server))
    AND ((@has_error      IS NULL) OR (DATALENGTH(error_message) >= 1 * @has_error))
    AND ((@status         IS NULL) OR (status = @status))
    AND ((@date_posted    IS NULL) OR (date_posted >= @date_posted))
  ORDER BY sdl.instance_id

  RETURN(@@error) -- 0 means success

END

GO
