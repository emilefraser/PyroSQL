SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dataprofile].[ProfileMetaData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dataprofile].[ProfileMetaData] AS' 
END
GO


ALTER   PROCEDURE [dataprofile].[ProfileMetaData]
 @Report TINYINT ,  --1 = 'TableStats', 2 = 'TableColumnMetadata'
 @SchemaName NVARCHAR(MAX) = N'',
 @ObjectlisttoSearch NVARCHAR(MAX) = N''
AS

 BEGIN
 SET NOCOUNT ON;

DROP TABLE IF EXISTS  #TblList
CREATE TABLE #TblList(Id INT IDENTITY(1,1),TableName NVARCHAR(200) )

DROP TABLE IF EXISTS  #Tblstats
CREATE TABLE #Tblstats (TableName NVARCHAR(200),NoOfRows NVARCHAR(100),ReservedSpace NVARCHAR(100)
                       ,DataSpace NVARCHAR(100),IndexSize NVARCHAR(100),UnusedSpace NVARCHAR(100)
					   ,LastUserUpdate DATETIME)

 IF ISNULL(@SchemaName,'') <> ''  OR ISNULL(@ObjectlisttoSearch,'') <> ''
 BEGIN

INSERT #TblList (TableName)
SELECT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName  
FROM Sys.tables
WHERE (Schema_name(schema_id) IN (SELECT value FROM STRING_SPLIT(@SchemaName, ','))
	OR CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) IN (SELECT value FROM STRING_SPLIT(@ObjectlisttoSearch, ',')))

 END ELSE
 BEGIN

INSERT #TblList (TableName)
SELECT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName  
FROM Sys.tables

 END

DECLARE @Tblstats TABLE(TableName NVARCHAR(200),NoOfRows NVARCHAR(100),ReservedSpace NVARCHAR(100)
                       ,DataSpace NVARCHAR(100),IndexSize NVARCHAR(100),UnusedSpace NVARCHAR(100)
					   )

DECLARE @I                        INT = 1
	   ,@tblname                  NVARCHAR(128) = N''
	   ,@last_user_update         DATETIME

WHILE @I <= (SELECT COUNT(1) FROM #TblList)
BEGIN

SELECT @tblname=TableName FROM #TblList WHERE Id = @I

INSERT @Tblstats 
EXEC sp_spaceused @tblname;  

SELECT TOP 1 @last_user_update=last_user_update 
FROM sys.dm_db_index_usage_stats   
WHERE object_id = OBJECT_ID(@tblname)
ORDER BY   last_user_update DESC

INSERT #Tblstats(TableName,NoOfRows,ReservedSpace,DataSpace,IndexSize,UnusedSpace,LastUserUpdate)
SELECT @tblname,NoOfRows,ReservedSpace,DataSpace,IndexSize,UnusedSpace,@last_user_update  
FROM @Tblstats

DELETE FROM @Tblstats

SET @I = @I + 1
END

  IF @Report = 1
  BEGIN

 ;WITH Systbl
 AS
 (
  SELECT DISTINCT CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) TableName 
        ,modify_date TableSchema_LastModifyDate
		,CASE WHEN is_replicated = 1 THEN 'Yes' ELSE 'No' END AS IsReplicated
		,CASE WHEN is_filetable = 1 THEN 'Yes' ELSE 'No' END AS IsFileTable
		,CASE WHEN is_memory_optimized = 1 THEN 'Yes' ELSE 'No' END AS IsMemoryOptimized
		,temporal_type_desc TemporalTypeDesc
		,CASE WHEN is_remote_data_archive_enabled = 1 THEN 'Yes' ELSE 'No' END AS IsStretchEnabled
		,CASE WHEN is_external = 1 THEN 'Yes' ELSE 'No' END AS IsExternal
		,CASE WHEN is_node = 1 OR is_edge = 1 THEN 'Yes' ELSE 'No' END IsGraphTable
 FROM sys.tables ST
 JOIN #TblList T
 ON CONCAT(SCHEMA_NAME(SCHEMA_ID),'.',name) COLLATE DATABASE_DEFAULT = T.TableName COLLATE DATABASE_DEFAULT
 )
SELECT B.*,A.TableSchema_LastModifyDate 
,A.IsMemoryOptimized
,A.IsExternal
,A.IsStretchEnabled
,A.IsFileTable
,A.IsGraphTable
,A.IsReplicated
,A.TemporalTypeDesc
FROM Systbl A
JOIN #Tblstats B
ON A.TableName COLLATE DATABASE_DEFAULT = B.TableName COLLATE DATABASE_DEFAULT


  END
  
 IF @Report = 2
 BEGIN

  SELECT  DISTINCT CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) TableName
		 ,C.name ColumnName
		 ,CASE WHEN TY.is_user_defined = 1 THEN (SELECT name FROM sys.types 
		                                         WHERE system_type_id = user_type_id
													AND  system_type_id =  TY.system_type_id)
		                                    ELSE TY.name 
		  END AS DataType
		  ,C.max_length
		  ,C.precision
		  ,C.scale
		  ,C.collation_name
		  ,CASE WHEN C.is_nullable = 1 THEN 'Yes' ELSE 'No' END AS IsNullable
		  ,CASE WHEN C.is_identity = 1 THEN 'Yes' ELSE 'No' END AS IsIdentity
		  ,CASE WHEN C.is_masked = 1 THEN 'Yes' ELSE 'No' END AS IsMasked
		  ,CASE WHEN C.is_hidden = 1 THEN 'Yes' ELSE 'No' END AS IsHidden
		  ,CASE WHEN C.is_computed = 1 THEN 'Yes' ELSE 'No' END AS IsComputed
		  ,CASE WHEN C.is_filestream = 1 THEN 'Yes' ELSE 'No' END AS IsFileStream
		  ,CASE WHEN C.is_sparse = 1 THEN 'Yes' ELSE 'No' END AS IsSparse
		  ,C.encryption_type_desc  EncryptionTypeDesc
FROM Sys.tables T
JOIN sys.columns C
	ON T.object_id = C.object_id
JOIN sys.types TY 
	ON C.[user_type_id] = TY.[user_type_id]
WHERE (Schema_name(T.schema_id) IN (SELECT value FROM STRING_SPLIT(@SchemaName, ','))
	OR CONCAT(SCHEMA_NAME(T.SCHEMA_ID),'.',T.name) IN (SELECT value FROM STRING_SPLIT(@ObjectlisttoSearch, ',')))

 END

  END

GO
