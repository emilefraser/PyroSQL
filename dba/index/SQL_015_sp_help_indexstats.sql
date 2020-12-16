--#################################################################################################
-- 2016-07-06 11:35:50.761 PARAGONDENTAL\lizaguirre
-- 
--#################################################################################################
USE master;

GO
IF OBJECT_ID('[dbo].[sp_help_indexstats]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_indexstats] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_indexstats] (@TableName SYSNAME = NULL)
AS
    DECLARE @id INT = Object_id(@TableName)

    SELECT Db_name(st.database_id)                          AS TheDatabase,
           Object_schema_name(st.object_id, st.database_id) AS SchemaName,
           Object_name(st.object_id, st.database_id)        AS TheTableName,
           ix.name AS IndexName,
           cmd = 'DROP INDEX ' + QUOTENAME(ix.name) + ' ON ' + QUOTENAME(Object_schema_name(st.object_id, st.database_id)) + '.' + QUOTENAME(Object_name(st.object_id, st.database_id)),
           st.*
    FROM   sys.dm_db_index_usage_stats st
    INNER JOIN sys.indexes ix ON st.index_id = ix.index_id AND st.object_id = ix.object_id
    WHERE  Db_name(st.database_id) = Db_name()
           AND ( @TableName IS NULL
                  OR st.object_id = @id )


GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_indexstats]'
--#################################################################################################
