USE master;
GO
IF OBJECT_ID('[dbo].[sp_hierarchy]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_hierarchy] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: Script All Tables/Procs/views/functions/objectsin foreign key hierachy/dependancy order
--create = lowest to highest,
--delete/drop = highest to lowest
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_hierarchy]
AS
BEGIN
  SET NOCOUNT ON
  CREATE TABLE #MyObjectHierarchy 
   (
    HID int identity(1,1) not null primary key,
    ObjectID int,
    SchemaName varchar(255),
    ObjectName varchar(255),
    ObjectType varchar(255),
    oTYPE int,
    SequenceOrder int
   )
  --our list of objects in dependancy order
  INSERT #MyObjectHierarchy (oTYPE,ObjectName,SchemaName,SequenceOrder)
    EXEC sp_msdependencies @intrans = 1 

UPDATE MyTarget
SET MyTarget.objectID   = objz.object_id,
    MyTarget.ObjectType = objz.type_desc
FROM #MyObjectHierarchy MyTarget
INNER JOIN sys.objects objz
ON MyTarget.ObjectName = objz.name
AND MyTarget.SchemaName = schema_name(objz.schema_id)

SELECT * FROM #MyObjectHierarchy ORDER BY HID
END
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_hierarchy'
GRANT EXECUTE ON dbo.sp_hierarchy TO PUBLIC;
--#################################################################################################
GO