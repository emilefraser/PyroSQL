use master
GO
IF OBJECT_ID('[dbo].[sp_help_MissingIndexes]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_MissingIndexes] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose: pull information from the DMVs related to missing indexes indexes
--do not blindly add indexes in the view, evaluate each index, and compare to existing indexes
--exec sp_help_unusedindexes
--#################################################################################################  
create procedure [dbo].[sp_help_MissingIndexes] (@MaxRecords int = 20)
AS
  SELECT 'Purpose: Top 20 missing indexes.' AS notes;
      SELECT TOP (@MaxRecords) 
       --SELECT TOP 20 
        [Total Cost] = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
		, avg_user_impact -- Query cost would reduce by this amount, on average.
		, user_seeks 
		, user_scans
		, DatabaseName = LEFT(statement,CHARINDEX('.',statement) -1)
        , TableName = statement
        , Tbl = REVERSE(LEFT(REVERSE(statement),CHARINDEX('.',REVERSE(statement)) -1))
        , [EqualityUsage] = equality_columns 
        , [InequalityUsage] = inequality_columns
        , [Include Columns] = included_columns,
        'CREATE INDEX [IX_' + REPLACE(REPLACE(REPLACE(REVERSE(LEFT(REVERSE(statement),CHARINDEX('.',REVERSE(statement)) -1)),'],[','_'),'[',''),']','')  + '_'
          + REPLACE(REPLACE(REPLACE(ISNULL(equality_columns,''),'], [','_'),'[',''),']','') 
          -- + CASE WHEN equality_columns IS NULL THEN '' ELSE '_' END 
           + REPLACE(REPLACE(REPLACE(ISNULL('_' + inequality_columns,''),'], [','_'),'[',''),']','') 
           +  CASE WHEN included_columns IS NOT NULL THEN '_Includes' ELSE '' END
          +'] ON ' + statement + '(' + ISNULL(equality_columns,'') 

                                     + ISNULL( CASE WHEN equality_columns IS NULL THEN '' ELSE ',' END  + inequality_columns,'') + ')' 
                                     + CASE WHEN included_columns IS NOT NULL THEN ' INCLUDE(' + included_columns + ')' ELSE '' END
        FROM sys.dm_db_missing_index_groups g 
        INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle 
        INNER JOIN sys.dm_db_missing_index_details d ON d.index_handle = g.index_handle
		WHERE LEFT(statement,CHARINDEX('.',statement) -1) = quotename(db_name())
        ORDER BY [Total Cost] DESC;
GO
GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_MissingIndexes]'
--#################################################################################################