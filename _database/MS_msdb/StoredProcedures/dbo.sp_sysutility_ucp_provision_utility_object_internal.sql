SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE dbo.sp_sysutility_ucp_provision_utility_object_internal
   @object_name sysname, @role_name sysname
WITH EXECUTE AS CALLER
AS
BEGIN
   DECLARE @sql_stmt nvarchar(max);
   DECLARE @grant_type NVARCHAR(20);
   DECLARE @object_type char(2);
   DECLARE @database_name sysname;
   DECLARE @quoted_object_name_with_dbo nvarchar(max);
   
   SET @database_name = DB_NAME();
   SET @quoted_object_name_with_dbo = 'dbo.' + QUOTENAME(@object_name);

   SELECT @object_type = [type] FROM sys.objects WHERE object_id = OBJECT_ID(@quoted_object_name_with_dbo);

   -- TSQL or CLR procs and non-inline functions
   --    P  - stored proc (TSQL)
   --    PC - stored proc (SQLCLR)
   --    FN - scalar function (TSQL)
   --    FS - scalar function (SQLCLR)
   IF (@object_type IN ('P', 'PC', 'FN', 'FS'))
   BEGIN
      SET @grant_type = 'EXECUTE';
   END

   -- Views, inline functions, tables
   --    V  - view
   --    IF - inline function (TSQL)
   --    U  - user table
   --    S  - system table
   --    TF - table-valued function (TSQL)
   --    FT - table-valued function (SQLCLR)
   ELSE IF (@object_type IN ('V', 'IF', 'U', 'S', 'FT', 'TF'))
   BEGIN
      SET @grant_type = 'SELECT';
   END;
   ELSE BEGIN
      -- The object '%s' does not exist in database '%s' or is invalid for this operation.
      RAISERROR (15009, 16, 1, @quoted_object_name_with_dbo, @database_name);
      RETURN;
   END;

   SELECT @sql_stmt = N'GRANT '+ @grant_type +' ON ' + @quoted_object_name_with_dbo + ' TO ' + QUOTENAME(@role_name);
   RAISERROR ('Executing: %s', 0, 1, @sql_stmt) WITH NOWAIT
   EXEC sp_executesql @sql_stmt;
END;

GO
