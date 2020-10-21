USE master;
GO
IF OBJECT_ID('[dbo].[sp_find]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_find] 
GO
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: find table/view columns containing search phrase 
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_find]                
  @findcolumn VARCHAR(50)                
AS                
BEGIN                
 SET NOCOUNT ON     
 --print object_name(@@PROCID) 
 SELECT 
 quotename(SchemaFound) + '.' + quotename(TableFound) As QualifiedObject,
   SchemaFound,
   TableFound, 
   ColumnFound,
   ObjectType,
   @findcolumn As SearchTerm,
   'SELECT * FROM ' +  quotename(SchemaFound) + '.' + quotename(TableFound) As cmd
 FROM   
   (       
    SELECT 
      0 AS SortOrder,
      SCHEMA_NAME(objz.schema_id) AS SchemaFound,
      objz.name AS TableFound,
      '' AS ColumnFound,
      objz.type_desc AS ObjectType              
    FROM sys.objects objz 
      WHERE SCHEMA_NAME(objz.schema_id) LIKE '%' + @findcolumn + '%'  
      AND objz.type_desc IN(
      'SYNONYM',
      'SYSTEM_TABLE',
       'VIEW',
       'SQL_TABLE_VALUED_FUNCTION',
       'SQL_STORED_PROCEDURE',
       'SQL_INLINE_TABLE_VALUED_FUNCTION',
       'USER_TABLE',
       'SQL_SCALAR_FUNCTION',
       'CLR_SCALAR_FUNCTION',
       'CLR_STORED_PROCEDURE',
       'CLR_TABLE_VALUED_FUNCTION',
       'SQL_TRIGGER')
    UNION
    SELECT 
      1 AS SortOrder,
      SCHEMA_NAME(objz.schema_id) AS SchemaFound,
      objz.name AS TableFound,
      '' AS ColumnFound,
      objz.type_desc AS ObjectType              
    FROM sys.objects objz 
      WHERE objz.name LIKE '%' + @findcolumn + '%'  
      AND objz.type_desc IN('SYNONYM',
       'SYSTEM_TABLE',
       'VIEW',
       'SQL_TABLE_VALUED_FUNCTION',
       'SQL_STORED_PROCEDURE',
       'SQL_INLINE_TABLE_VALUED_FUNCTION',
       'USER_TABLE',
       'SQL_SCALAR_FUNCTION',
       'CLR_SCALAR_FUNCTION',
       'CLR_STORED_PROCEDURE',
       'CLR_TABLE_VALUED_FUNCTION',
       'SQL_TRIGGER')
    UNION ALL   
    SELECT 
      2 AS SortOrder,
      SCHEMA_NAME(objz.schema_id) AS SchemaFound,
      objz.name AS TableFound,
      colz.name AS ColumnFound,
      objz.type_desc AS ObjectType                
    FROM sys.objects objz              
      INNER JOIN sys.columns colz 
        ON objz.object_id=colz.object_id              
    WHERE colz.name LIKE '%' + @findcolumn + '%' 
          AND objz.type_desc IN('SYSTEM_TABLE',
       'VIEW',
          'USER_TABLE')    
   )  X       
   ORDER BY   
     SortOrder,
     TableFound,
     ColumnFound  
END --PROC  
GO

--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject 'sp_find'
GRANT EXECUTE ON dbo.sp_find TO PUBLIC;
--#################################################################################################
GO