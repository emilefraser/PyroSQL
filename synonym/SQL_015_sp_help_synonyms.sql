USE master;
GO
IF OBJECT_ID('[dbo].[sp_help_synonyms]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_synonyms] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script displays all references, including cross server/cross database references
--EXECUTE sp_ms_marksystemobject 'sp_help_synonyms'
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_synonyms]
AS
DECLARE @vbCrLf varchar(2); 
SET @vbCrLf = CHAR(13) + CHAR(10);
SELECT name,

'IF EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                        + name 
                        + ''''
                        + ' AND base_object_name <> ''' + base_object_name + ''')'
                        + @vbCrLf
                        + '  DROP SYNONYM ' + quotename(SCHEMA_NAME(schema_id)) + '.'  + quotename(name) + ''
                        + @vbCrLf
                        +'GO'
                        + @vbCrLf
                        +'IF NOT EXISTS(SELECT * FROM sys.synonyms WHERE name = ''' 
                        + name 
                        + ''')'
                        + @vbCrLf
                        + 'CREATE SYNONYM ' + quotename(SCHEMA_NAME(schema_id)) + '.'  + quotename(name) + ' FOR ' + base_object_name +';'
                        from sys.synonyms;
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_help_synonyms'
GRANT EXECUTE ON sp_help_synonyms TO PUBLIC
--#################################################################################################
