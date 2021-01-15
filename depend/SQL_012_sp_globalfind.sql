IF OBJECT_ID('[dbo].[sp_globalfind]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_globalfind] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: find table/view columns containing search phrase, but in all databases 
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_globalfind]                
  @findcolumn VARCHAR(50)                
AS                
BEGIN                
 SET NOCOUNT ON     
 
IF OBJECT_ID('tempdb.[dbo].[#tmp]') IS NOT NULL 
DROP TABLE [dbo].[#tmp] 
CREATE TABLE [dbo].[#tmp] ( 
[DatabaseName] SYSNAME                          NOT NULL,
[QualifiedObjectName]varchar(500)                   NULL,
[SchemaFound]   SYSNAME                             NULL,
[TableFound]   SYSNAME                          NOT NULL,
[ColumnFound]  NVARCHAR(128)                        NULL,
[ObjectType]   NVARCHAR(60)                         NULL)

--declare @findcolumn varchar(128)= 'MthHour'
 --print object_name(@@PROCID) 
DECLARE @cmd varchar(max) = '
INSERT INTO [#tmp]([DatabaseName],[QualifiedObjectName],[SchemaFound],[TableFound],[ColumnFound],[ObjectType])
 SELECT 
   ''[?]'' AS DatabaseName,
   QUOTENAME(SchemaFound) + ''.'' + QUOTENAME(TableFound),
   SchemaFound,
   TableFound, 
   ColumnFound,
   ObjectType 
 FROM   
   (       
    SELECT 
      1 AS SortOrder,
      scmz.name AS SchemaFound,
      objz.name AS TableFound,
      '''' AS ColumnFound,
      objz.type_desc AS ObjectType              
    FROM [?].sys.objects objz 
    INNER JOIN [?].sys.schemas scmz
    ON objz.schema_id = scmz.schema_id
      WHERE objz.name LIKE ''%' + @findcolumn + '%''  
      AND objz.type_desc IN(''SYSTEM_TABLE'',
       ''VIEW'',
       ''SQL_TABLE_VALUED_FUNCTION'',
       ''SQL_STORED_PROCEDURE'',
       ''SQL_INLINE_TABLE_VALUED_FUNCTION'',
       ''USER_TABLE'',
       ''SQL_SCALAR_FUNCTION'')
    UNION ALL   
    SELECT 
      2 AS SortOrder,
     scmz.name AS SchemaFound,
      objz.name AS TableFound,
      colz.name AS ColumnFound,
      objz.type_desc AS ObjectType                
    FROM [?].sys.objects objz              
    INNER JOIN [?].sys.schemas scmz
    ON objz.schema_id = scmz.schema_id
      INNER JOIN [?].sys.columns colz 
        ON objz.object_id=colz.object_id              
    WHERE colz.name LIKE ''%' + @findcolumn + '%'' 
          AND objz.type_desc IN(''SYSTEM_TABLE'',
       ''VIEW'',
          ''USER_TABLE'')    
   )  X       
   ORDER BY   
     SortOrder,
     TableFound,
     ColumnFound '
--print @cmd
EXEC sp_MsForEachDb @cmd
SELECT * FROM #tmp
END --PROC  

GO
