USE master;
GO
IF OBJECT_ID('[dbo].[sp_help_references]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_references] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script displays all references, including cross server/cross database references
--EXECUTE sp_ms_marksystemobject 'sp_help_references'
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_references] @ObjectName sysname = NULL,@ShowAll INT = 0
AS 
BEGIN
  IF @ObjectName IS NOT NULL 
    SET @ShowAll = 1
  SELECT 
    SCHEMA_NAME(so.SCHEMA_ID) AS SchemaName,
    so.name AS ObjectName,
    so.type_desc,
    sed.referenced_server_name,
    sed.referenced_database_name,
    sed.referenced_schema_name,
    sed.referenced_entity_name,*
  FROM sys.sql_expression_dependencies sed
    INNER JOIN sys.objects so 
      ON sed.referencing_id = so.OBJECT_ID
  WHERE 1 = CASE 
              WHEN @ShowAll = 1 
              THEN 1
              WHEN  @ShowAll =0 AND sed.referenced_server_name IS NOT NULL OR sed.referenced_database_name IS NOT NULL
              THEN 1
              ELSE 0 
            END
    AND 1 = CASE
              WHEN @ObjectName IS NULL
              THEN 1
              WHEN sed.referenced_entity_name = @ObjectName
              THEN 1 
              ELSE 0
            END
END --PROC

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_help_references'
GRANT EXECUTE ON dbo.sp_help_references TO PUBLIC;
--#################################################################################################
