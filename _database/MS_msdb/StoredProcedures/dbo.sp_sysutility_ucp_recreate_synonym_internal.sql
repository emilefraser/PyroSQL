SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE PROCEDURE [dbo].[sp_sysutility_ucp_recreate_synonym_internal]
   @synonym_name sysname, @database_name sysname, @schema_name sysname, @object_name sysname
WITH EXECUTE AS CALLER
AS
BEGIN
   DECLARE @null_column nvarchar(100)
   SET @null_column = NULL

   IF (@synonym_name IS NULL OR @synonym_name = N'')
        SET @null_column = '@synonym_name'
   ELSE IF (@object_name IS NULL OR @object_name = N'')
        SET @null_column = '@object_name'

   IF @null_column IS NOT NULL
   BEGIN
        RAISERROR(14043, -1, -1, @null_column, 'sp_sysutility_ucp_recreate_synonym')
        RETURN(1)
   END

   IF  EXISTS (SELECT name FROM sys.objects WHERE object_id = OBJECT_ID(@synonym_name) )
   BEGIN
      DECLARE @drop_statement nvarchar(600)
      SET @drop_statement = N'DROP SYNONYM [dbo].' + QUOTENAME(@synonym_name)
      RAISERROR ('Executing: %s', 0, 1, @drop_statement) WITH NOWAIT;
      EXEC  sp_executesql @drop_statement
   END

   DECLARE @full_object_name nvarchar(776) = QUOTENAME(@database_name) + '.' + QUOTENAME(@schema_name) + '.' + QUOTENAME(@object_name)
   DECLARE @create_statement nvarchar(1060)
   SET @create_statement = N'CREATE SYNONYM [dbo].' + QUOTENAME(@synonym_name) + ' FOR ' + @full_object_name
   RAISERROR ('Executing: %s', 0, 1, @create_statement) WITH NOWAIT;
   EXEC  sp_executesql @create_statement
END

GO
