SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_add_job
  @job_name                     sysname,
  @enabled                      TINYINT          = 1,        -- 0 = Disabled, 1 = Enabled
  @description                  NVARCHAR(512)    = NULL,
  @start_step_id                INT              = 1,
  @category_name                sysname          = NULL,
  @category_id                  INT              = NULL,     -- A language-independent way to specify which category to use
  @owner_login_name             sysname          = NULL,     -- The procedure assigns a default
  @notify_level_eventlog        INT              = 2,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_email           INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_netsend         INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_level_page            INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @notify_email_operator_name   sysname          = NULL,
  @notify_netsend_operator_name sysname          = NULL,
  @notify_page_operator_name    sysname          = NULL,
  @delete_level                 INT              = 0,        -- 0 = Never, 1 = On Success, 2 = On Failure, 3 = Always
  @job_id                       UNIQUEIDENTIFIER = NULL OUTPUT,
  @originating_server           sysname           = NULL      -- For SQLAgent use only
AS
BEGIN
  DECLARE @retval                     INT
  DECLARE @notify_email_operator_id   INT
  DECLARE @notify_netsend_operator_id INT
  DECLARE @notify_page_operator_id    INT
  DECLARE @owner_sid                  VARBINARY(85)
  DECLARE @originating_server_id      INT

  SET NOCOUNT ON

  -- If this is Azure SQL Database - Managed Instance throw an exception for unsupported option
  IF (SERVERPROPERTY('EngineEdition') = 8)
  BEGIN
    IF (@notify_level_netsend <> 0)
    BEGIN
      RAISERROR(41914, -1, 9, 'NetSend');
      RETURN(1) -- Failure
    END
    SET @notify_level_eventlog = 0
  END

  -- Remove any leading/trailing spaces from parameters (except @owner_login_name)
  SELECT @originating_server           = UPPER(LTRIM(RTRIM(@originating_server)))
  SELECT @job_name                     = LTRIM(RTRIM(@job_name))
  SELECT @description                  = LTRIM(RTRIM(@description))
  SELECT @category_name                = LTRIM(RTRIM(@category_name))
  SELECT @notify_email_operator_name   = LTRIM(RTRIM(@notify_email_operator_name))
  SELECT @notify_netsend_operator_name = LTRIM(RTRIM(@notify_netsend_operator_name))
  SELECT @notify_page_operator_name    = LTRIM(RTRIM(@notify_page_operator_name))
  SELECT @originating_server_id        = NULL

  -- Turn [nullable] empty string parameters into NULLs
  IF (@originating_server           = N'') SELECT @originating_server           = NULL
  IF (@description                  = N'') SELECT @description                  = NULL
  IF (@category_name                = N'') SELECT @category_name                = NULL
  IF (@notify_email_operator_name   = N'') SELECT @notify_email_operator_name   = NULL
  IF (@notify_netsend_operator_name = N'') SELECT @notify_netsend_operator_name = NULL
  IF (@notify_page_operator_name    = N'') SELECT @notify_page_operator_name    = NULL

  IF (@originating_server IS NULL) OR (@originating_server = '(LOCAL)')
    SELECT @originating_server= UPPER(CONVERT(sysname, SERVERPROPERTY('ServerName')))

  --only members of sysadmins role can set the owner
  IF (@owner_login_name IS NOT NULL AND ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND (@owner_login_name <> SUSER_SNAME())
  BEGIN
    RAISERROR(14515, -1, -1)
    RETURN(1) -- Failure
  END

  -- Default the owner (if not supplied or if a non-sa is [illegally] trying to create a job for another user)
  -- allow special account only when caller is sysadmin
  IF (@owner_login_name = N'$(SQLAgentAccount)')  AND
     (ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 1)
  BEGIN
    SELECT @owner_sid = 0xFFFFFFFF
  END
  ELSE
  IF (@owner_login_name IS NULL) OR ((ISNULL(IS_SRVROLEMEMBER(N'sysadmin'), 0) = 0) AND (@owner_login_name <> SUSER_SNAME()))
  BEGIN
    SELECT @owner_sid = SUSER_SID()
  END
  ELSE
  BEGIN
    --force case insensitive comparation for NT users
    SELECT @owner_sid = SUSER_SID(@owner_login_name, 0) -- If @owner_login_name is invalid then SUSER_SID() will return NULL
  END

  -- Default the description (if not supplied)
  IF (@description IS NULL)
    SELECT @description = FORMATMESSAGE(14571)

  -- If a category ID is provided this overrides any supplied category name
  EXECUTE @retval = sp_verify_category_identifiers '@category_name',
                                                   '@category_id',
                                                    @category_name OUTPUT,
                                                    @category_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  -- Check parameters
  EXECUTE @retval = sp_verify_job NULL,  --  The job id is null since this is a new job
                                  @job_name,
                                  @enabled,
                                  @start_step_id,
                                  @category_name,
                                  @owner_sid                  OUTPUT,
                                  @notify_level_eventlog,
                                  @notify_level_email         OUTPUT,
                                  @notify_level_netsend       OUTPUT,
                                  @notify_level_page          OUTPUT,
                                  @notify_email_operator_name,
                                  @notify_netsend_operator_name,
                                  @notify_page_operator_name,
                                  @delete_level,
                                  @category_id                OUTPUT,
                                  @notify_email_operator_id   OUTPUT,
                                  @notify_netsend_operator_id OUTPUT,
                                  @notify_page_operator_id    OUTPUT,
                                  @originating_server         OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure


  SELECT @originating_server_id = originating_server_id
  FROM msdb.dbo.sysoriginatingservers_view
  WHERE (originating_server = @originating_server)
  IF (@originating_server_id IS NULL)
  BEGIN
    RAISERROR(14370, -1, -1)
    RETURN(1) -- Failure
  END


  IF (@job_id IS NULL)
  BEGIN
    -- Assign the GUID
    SELECT @job_id = NEWID()
  END
  ELSE
  BEGIN
    -- A job ID has been provided, so check that the caller is SQLServerAgent (inserting an MSX job)
    IF (PROGRAM_NAME() NOT LIKE N'SQLAgent%')
    BEGIN
      RAISERROR(14274, -1, -1)
      RETURN(1) -- Failure
    END
  END

  INSERT INTO msdb.dbo.sysjobs
         (job_id,
          originating_server_id,
          name,
          enabled,
          description,
          start_step_id,
          category_id,
          owner_sid,
          notify_level_eventlog,
          notify_level_email,
          notify_level_netsend,
          notify_level_page,
          notify_email_operator_id,
          notify_netsend_operator_id,
          notify_page_operator_id,
          delete_level,
          date_created,
          date_modified,
          version_number)
  VALUES  (@job_id,
          @originating_server_id,
          @job_name,
          @enabled,
          @description,
          @start_step_id,
          @category_id,
          @owner_sid,
          @notify_level_eventlog,
          @notify_level_email,
          @notify_level_netsend,
          @notify_level_page,
          @notify_email_operator_id,
          @notify_netsend_operator_id,
          @notify_page_operator_id,
          @delete_level,
          GETDATE(),
          GETDATE(),
          1) -- Version number 1
  SELECT @retval = @@error

  -- NOTE: We don't notify SQLServerAgent to update it's cache (we'll do this in sp_add_jobserver)

  RETURN(@retval) -- 0 means success
END

GO
