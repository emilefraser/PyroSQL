USE master;
GO

IF OBJECT_ID('[dbo].[sp_count_indexes]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_count_indexes] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: count indexes on a per object basis for reference
--general rule of thumb is to rething tables with more than five indexes.
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_count_indexes](@WhichObject sysname=NULL)
AS
SELECT 
  OBJECT_SCHEMA_NAME(IDXZ.object_id)               AS SchemaName,
  OBJECT_NAME(IDXZ.object_id)                      AS ObjectName,
  OBJZ.type_desc                                   AS ObjectType,
SUM(CASE WHEN IDXZ.index_id = 0 THEN 1 ELSE 0 END) AS IsHeap,
SUM(CASE WHEN IDXZ.index_id = 1 THEN 1 ELSE 0 END) AS IsClustered,
SUM(CASE WHEN IDXZ.index_id > 1 THEN 1 ELSE 0 END) AS TotalUserIndexes
FROM sys.indexes IDXZ
  INNER JOIN SYS.OBJECTS OBJZ
    ON idxz.object_id = objz.object_id
WHERE OBJECT_SCHEMA_NAME(IDXZ.object_id)  <> 'SYS'
  AND (objz.object_id = OBJECT_ID(@WhichObject) OR @WhichObject IS NULL)
  AND idxz.is_hypothetical = 0
GROUP BY IDXZ.object_id,OBJZ.type_desc
ORDER BY TotalUserIndexes DESC, SchemaName,ObjectName
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_count_indexes]'
--#################################################################################################
