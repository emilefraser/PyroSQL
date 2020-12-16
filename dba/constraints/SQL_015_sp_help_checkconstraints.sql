use master;
GO
IF OBJECT_ID('[dbo].[sp_help_checkconstraints]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_checkconstraints] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE sp_help_checkconstraints
AS
BEGIN
SET NOCOUNT ON
SELECT 
 QUOTENAME(SCHEMA_NAME(tabz.SCHEMA_ID)) + '.' + QUOTENAME(tabz.name) AS QualifiedObjectName,
  SCHEMA_NAME(tabz.SCHEMA_ID) AS SchemaName, 
  tabz.name AS TableName,
  colz.name AS ColumnName,
  defz.definition AS ConstraintDefinition,
  defz.name AS ConstraintName,
  defz.* 
FROM sys.check_constraints defz
INNER JOIN sys.tables tabz ON defz.parent_object_id = tabz.OBJECT_ID
INNER JOIN sys.columns colz ON tabz.OBJECT_ID = colz.OBJECT_ID AND defz.parent_column_id = colz.column_id;
END; -- PROC


GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_checkconstraints]'
--#################################################################################################
