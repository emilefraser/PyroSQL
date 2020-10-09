SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_create_user_credential_sp
   @username      nvarchar(128),
   @password      nvarchar(128),
   @credential_id int            OUTPUT
AS
   SET NOCOUNT ON
   DECLARE @rc int
   DECLARE @credential_name UNIQUEIDENTIFIER
   DECLARE @credential_name_as_str varchar(40)
   DECLARE @sql NVARCHAR(max)

   -- create a GUID as the name for the credential
   SET @credential_name = newid()
   SET @credential_name_as_str = convert(varchar(40), @credential_name)
   SET @sql = N'CREATE CREDENTIAL [' + @credential_name_as_str
            + N'] WITH IDENTITY = ' + QUOTENAME(@username, '''')
            + N', SECRET = ' + QUOTENAME(ISNULL(@password, N''), '''')

   EXEC @rc = sp_executesql @statement = @sql
   IF(@rc <> 0)
      RETURN @rc

   SELECT @credential_id = credential_id 
   FROM sys.credentials
   WHERE name = convert(sysname, @credential_name)
    IF(@credential_id IS NULL)
   BEGIN
      RAISERROR(14616, -1, -1, @credential_name_as_str)
      RETURN 1
   END

   RETURN(0)

GO
