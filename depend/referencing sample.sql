--=========================================================================
--=========================================================================
--== utlGetAllDependentObjectsRecursive - Uses recursive common table
--==     expression to recursively get all the dependent objects as well
--==     as the child objects and child's child objects of a 
--==     Stored Procedure or View or Function.  can be easily modified to 
--==     include all other types of Objects
--=========================================================================
--=========================================================================
CREATE OR ALTER PROCEDURE utlGetAllDependentObjectsRecursive
(
   -- Supports Stored Proc, View, User Function, User Table
   @PARAM_OBJECT_NAME VARCHAR(500)
)
AS
BEGIN
    WITH CTE_DependentObjects AS
    (
        SELECT DISTINCT 
        b.object_id AS UsedByObjectId, 
        b.name AS UsedByObjectName, b.type AS UsedByObjectType, 
        c.object_id AS DependentObjectId, 
        c.name AS DependentObjectName , c.type AS DependenObjectType
        FROM  sys.sysdepends a
        INNER JOIN sys.objects b ON a.id = b.object_id
        INNER JOIN sys.objects c ON a.depid = c.object_id
        WHERE b.type IN ('P','V', 'FN') AND c.type IN ('U', 'P', 'V', 'FN') 
    ),
    CTE_DependentObjects2 AS
    (
       SELECT 
          UsedByObjectId, UsedByObjectName, UsedByObjectType,
          DependentObjectId, DependentObjectName, DependenObjectType, 
          1 AS Level
       FROM CTE_DependentObjects a
       WHERE a.UsedByObjectName = @PARAM_OBJECT_NAME
       UNION ALL 
       SELECT 
          a.UsedByObjectId, a.UsedByObjectName, a.UsedByObjectType,
          a.DependentObjectId, a.DependentObjectName, a.DependenObjectType, 
          (b.Level + 1) AS Level
       FROM CTE_DependentObjects a
       INNER JOIN  CTE_DependentObjects2 b 
          ON a.UsedByObjectName = b.DependentObjectName
    )
    SELECT DISTINCT * FROM CTE_DependentObjects2 
    ORDER BY Level, DependentObjectName    
END 


EXEC dbo.utlGetAllDependentObjectsRecursive 'raw.HUB_SalesInvoice'