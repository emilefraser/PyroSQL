SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF

CREATE PROCEDURE dbo.sysmail_drop_user_credential_sp
   @credential_name sysname
AS
   SET NOCOUNT ON
   DECLARE @rc int
   DECLARE @sql NVARCHAR(max)

   -- Drop credential DDL
   SET @sql = N'DROP CREDENTIAL ' + QUOTENAME(@credential_name)

   EXEC @rc = sp_executesql @statement = @sql
   IF(@rc <> 0)
      RETURN @rc

   RETURN(0)

GO
