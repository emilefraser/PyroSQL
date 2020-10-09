SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sp_notify_operator
  @profile_name           sysname       = NULL,
  --name of Database Mail profile to be used for sending email, cannot be null
  @id                     INT            = NULL,
  @name                   sysname        = NULL,
  --mutual exclusive, one and only one should be non null. Specify the operator whom mail adress will be used to send this email
  @subject                NVARCHAR(256)  = NULL,
  @body                   NVARCHAR(MAX)  = NULL,
  -- This is the body of the email message
  @file_attachments       NVARCHAR(512)  = NULL,
  @mail_database          sysname       = N'msdb'
  -- Have infrastructure in place to support this but disabled by default
  -- For first implementation we will have this parameters but using it will generate an error - not implemented yet.
AS
BEGIN
  DECLARE @retval INT
  DECLARE @email_address NVARCHAR(100)
  DECLARE @enabled TINYINT
  DECLARE @qualified_sp_sendmail sysname
  DECLARE @db_id INT

  SET NOCOUNT ON

  -- Remove any leading/trailing spaces from parameters
  SELECT @profile_name              = LTRIM(RTRIM(@profile_name))
  SELECT @name                      = LTRIM(RTRIM(@name))
  SELECT @file_attachments          = LTRIM(RTRIM(@file_attachments))
  SELECT @mail_database          = LTRIM(RTRIM(@mail_database))


  IF @profile_name       = ''    SELECT @profile_name      = NULL
  IF @name               = ''    SELECT @name              = NULL
  IF @file_attachments   = ''    SELECT @file_attachments  = NULL
  IF @mail_database      = ''    SELECT @mail_database      = NULL

  EXECUTE @retval = sp_verify_operator_identifiers '@name',
                                                   '@id',
                                                   @name OUTPUT,
                                                   @id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  --is operator enabled?
  SELECT @enabled = enabled, @email_address = email_address FROM sysoperators WHERE id = @id
  IF @enabled = 0
  BEGIN
    RAISERROR(14601, 16, 1, @name)
    RETURN 1
  END

  IF @email_address IS NULL
  BEGIN
    RAISERROR(14602, 16, 1, @name)
    RETURN 1
  END

  SELECT @qualified_sp_sendmail = @mail_database + '.dbo.sp_send_dbmail'

  EXEC   @retval = @qualified_sp_sendmail @profile_name = @profile_name,
                               @recipients       = @email_address,
                               @subject          = @subject,
                               @body              = @body,
                               @file_attachments = @file_attachments
  RETURN @retval
END

GO
