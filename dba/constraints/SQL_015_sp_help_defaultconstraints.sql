use master;
GO

IF OBJECT_ID('[dbo].[sp_help_defaultconstraints]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_defaultconstraints] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE sp_help_defaultconstraints(@tablename sysname = NULL)
AS
BEGIN
SET NOCOUNT ON
SELECT 
 QUOTENAME(SCHEMA_NAME(tabz.SCHEMA_ID)) + '.' + QUOTENAME(tabz.name) AS QualifiedObjectName,
  SCHEMA_NAME(tabz.SCHEMA_ID) AS SchemaName, 
  tabz.name AS TableName,
  colz.name AS ColumnName,
  defz.definition AS DefaultDefinition,
  CASE 
      WHEN LTRIM(RTRIM( defz.definition)) like'((%' 
      AND  LTRIM(RTRIM( defz.definition)) like'%))'
      THEN SUBSTRING(LTRIM(RTRIM( defz.definition)),2,len(LTRIM(RTRIM( defz.definition))) - 2)
      ELSE defz.definition
    END As CleanedDefault,
  defz.name AS ConstraintName,
   'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(tabz.schema_id)) 
  + '.' 
   + QUOTENAME(tabz.name)  + ' ADD ' + 
  'CONSTRAINT ' 
  + QUOTENAME(defz.name) 
  + ' DEFAULT ' 
  + CASE 
      WHEN LTRIM(RTRIM( defz.definition)) like'((%' 
      AND  LTRIM(RTRIM( defz.definition)) like'%))'
      THEN SUBSTRING(LTRIM(RTRIM( defz.definition)),2,len(LTRIM(RTRIM( defz.definition))) - 2)
      ELSE defz.definition
    END
  + ' FOR  ' 
  + QUOTENAME( colz.name) 

  --defz.* 
FROM sys.default_constraints defz
INNER JOIN sys.tables tabz ON defz.parent_object_id = tabz.OBJECT_ID
INNER JOIN sys.columns colz ON tabz.OBJECT_ID = colz.OBJECT_ID AND defz.parent_column_id = colz.column_id
WHERE (tabz.OBJECT_ID = object_id(@tablename) Or @tablename IS NULL);
END; -- PROC

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_defaultconstraints]'
--#################################################################################################
