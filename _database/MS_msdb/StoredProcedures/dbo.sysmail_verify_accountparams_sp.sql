SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_verify_accountparams_sp
   @use_default_credentials bit,
   @mailserver_type sysname      OUTPUT,  -- @mailserver_type must be provided. Usually SMTP
   @username      nvarchar(128)  OUTPUT, -- returns trimmed value, NULL if empty
   @password      nvarchar(128)  OUTPUT  -- returns trimmed value,  NULL if empty
AS
   SET @username = LTRIM(RTRIM(@username))
   SET @password = LTRIM(RTRIM(@password))
   SET @mailserver_type = LTRIM(RTRIM(@mailserver_type))

    IF(@username = N'')         SET @username = NULL
    IF(@password = N'')         SET @password = NULL
    IF(@mailserver_type = N'')  SET @mailserver_type = NULL

   IF(@mailserver_type IS NULL)
   BEGIN
      RAISERROR(14614, -1, -1, @mailserver_type)   
      RETURN (1)  
   END

   -- default credentials should supercede any explicit credentials passed in
   IF((@use_default_credentials = 1) AND (@username IS NOT NULL))
   BEGIN
      RAISERROR(14666, -1, -1)   
      RETURN (1)
   END  

   --If a password is specified then @username must be a non empty string
   IF((@password IS NOT NULL) AND (@username IS NULL))
   BEGIN
      RAISERROR(14615, -1, -1)   
      RETURN (1)
   END  

   RETURN(0) -- SUCCESS

GO
