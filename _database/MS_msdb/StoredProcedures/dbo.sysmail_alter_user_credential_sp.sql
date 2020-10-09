SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_alter_user_credential_sp
   @credential_name sysname,
   @username      nvarchar(128),
   @password      nvarchar(128)
AS
   SET NOCOUNT ON
   DECLARE @rc int
   DECLARE @sql NVARCHAR(max)

   -- alter credential DDL
   SET @sql = N'ALTER CREDENTIAL ' + QUOTENAME(@credential_name)
         + N' WITH IDENTITY = ' + QUOTENAME(@username, '''')
         + N', SECRET = ' + QUOTENAME(ISNULL(@password, N''), '''')

   EXEC @rc = sp_executesql @statement = @sql
   IF(@rc <> 0)
      RETURN @rc

   RETURN(0)

GO
