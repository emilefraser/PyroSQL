SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sp_update_proxy
   @proxy_id [int] = NULL,
   @proxy_name [sysname] = NULL,
   -- must specify only one of above parameter identify the proxy
   @credential_name [sysname] = NULL,
   @credential_id [INT] = NULL,
   @new_name [sysname] = NULL,
   @enabled [tinyint] = NULL,
   @description [nvarchar](512) = NULL
AS
BEGIN
   DECLARE  @x_new_name [sysname]
   DECLARE  @x_credential_id [int]
   DECLARE  @x_enabled [tinyint]
   DECLARE @x_description [nvarchar](512)
   DECLARE @x_credential_date_created [datetime]
   DECLARE @user_sid VARBINARY(85)
      DECLARE @full_name [sysname] --two sysnames + \
   DECLARE @retval   INT
   SET NOCOUNT ON

   EXECUTE @retval = sp_verify_proxy_identifiers '@proxy_name',
                                                  '@proxy_id',
                                                   @proxy_name OUTPUT,
                                                   @proxy_id   OUTPUT
  IF (@retval <> 0)
    RETURN(1) -- Failure

  IF @credential_id IS NOT NULL OR @credential_name IS NOT NULL
  BEGIN
     EXECUTE @retval = sp_verify_credential_identifiers '@credential_name',
                                                    '@credential_id',
                                                    @credential_name OUTPUT,
                                                    @credential_id   OUTPUT
    IF (@retval <> 0)
      RETURN(1) -- Failure
  END

   -- Remove any leading/trailing spaces from parameters
   SELECT @new_name                = LTRIM(RTRIM(@new_name))
   SELECT @description             = LTRIM(RTRIM(@description))
  -- Turn [nullable] empty string parameters into NULLs
  IF @new_name      = '' SELECT @new_name = NULL
  IF @description    = '' SELECT @description = NULL

  -- Set the x_ (existing) variables
  SELECT    @x_new_name      = name,
    @x_credential_id = credential_id,
      @x_enabled       = enabled,
      @x_description   = description,
    @x_credential_date_created = credential_date_created
   FROM sysproxies
   WHERE proxy_id = @proxy_id

  --get the new date from credential table
  IF  (@credential_id IS NOT NULL)
    SELECT @x_credential_date_created = create_date FROM master.sys.credentials
    WHERE  credential_id = @credential_id

    -- Fill out the values for all non-supplied parameters from the existing values
   IF    (@new_name      IS NULL) SELECT   @new_name          =           @x_new_name
   IF (@credential_id IS NULL) SELECT   @credential_id     =           @x_credential_id
   IF (@enabled       IS NULL) SELECT   @enabled           =           @x_enabled
   IF (@description   IS NULL) SELECT   @description       =           @x_description

  -- warn if the user_domain\user_name does not exist
  SELECT @full_name = credential_identity from master.sys.credentials
  WHERE  credential_id = @credential_id

  --force case insensitive comparation for NT users
  SELECT @user_sid = SUSER_SID(@full_name, 0)
  IF @user_sid IS NULL
  BEGIN
    RAISERROR(14529, -1, -1, @full_name)
    RETURN(1)
  END

  -- Finally, do the actual UPDATE
  UPDATE msdb.dbo.sysproxies
   SET
   name     =  @new_name,
   credential_id  =  @credential_id,
   user_sid =  @user_sid,
   enabled     =  @enabled,
   description =  @description,
   credential_date_created = @x_credential_date_created  --@x_ is OK in this case
   WHERE proxy_id = @proxy_id
END

GO
