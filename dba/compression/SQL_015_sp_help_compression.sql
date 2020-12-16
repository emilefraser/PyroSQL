USE master;
GO
IF OBJECT_ID('[dbo].[sp_help_compression]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_compression] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
--#################################################################################################
--developer utility function added by Lowell, used in SQL Server Management Studio 
--Purpose:Get currently compressed tables, and alternatively, an estimate for a passed sysname
-- Get compression estimates for selected table
--#################################################################################################

CREATE PROCEDURE [dbo].[sp_help_compression]
  @TBL                sysname = NULL
AS
BEGIN
  SET NOCOUNT ON
  DECLARE     @TABLE_ID               INT,
              @SCHEMANAME             VARCHAR(255),
              @TBLNAME                VARCHAR(200);

--##############################################################################
-- INITIALIZE
--##############################################################################
  --does the tablename contain a schema?
SELECT 
quotename(schema_name(objz.schema_id)) + '.' + quotename(objz.name) As QualifiedObjectName,
schema_name(objz.schema_id) As SchemaName,
objz.name As TableName, 
ix.name, 
ix.index_id,
--objz.object_id, 
--sp.partition_id, 
--sp.partition_number, 
--sp.data_compression,
sp.data_compression_desc,
CASE 
  WHEN sp.data_compression_desc = 'NONE'
  THEN CASE 
       WHEN ix.index_id= 0
       THEN 'RAISERROR(''Rebuilding ' + quotename(OBJECT_SCHEMA_NAME([objz].[object_id])) 
            + '.' + quotename(OBJECT_NAME([objz].[object_id])) + ''',0,1) WITH NOWAIT;' + CHAR(13) + CHAR(10)
            + 'ALTER TABLE ' 
            + quotename(OBJECT_SCHEMA_NAME([objz].[object_id])) 
            + '.' + quotename(OBJECT_NAME([objz].[object_id])) 
            + ' REBUILD WITH (data_compression = PAGE) ;' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
       ELSE 'RAISERROR(''Rebuilding ' + quotename(OBJECT_SCHEMA_NAME([objz].[object_id])) 
            + '.' + quotename(OBJECT_NAME([objz].[object_id])) + ''',0,1) WITH NOWAIT;' + CHAR(13) + CHAR(10)
            + 'ALTER INDEX ' 
            + quotename(ix.[name]) 
            + ' ON ' 
            + quotename(OBJECT_SCHEMA_NAME([objz].[object_id])) 
            + '.' + quotename(OBJECT_NAME([objz].[object_id])) 
            + ' REBUILD WITH ( DATA_COMPRESSION = PAGE ) ;' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
       END
  ELSE ''
END AS [CompressionCommand] 


FROM sys.partitions SP WITH(NOLOCK)
INNER JOIN sys.tables objz WITH(NOLOCK) ON objz.object_id = sp.object_id 
LEFT OUTER JOIN sys.indexes IX WITH(NOLOCK) ON sp.object_id = ix.object_id and sp.index_id = ix.index_id
--WHERE sp.data_compression =0
ORDER BY sp.data_compression_desc,OBJECT_NAME([objz].[object_id])


  SELECT @TABLE_ID   =                    object_id(@TBL),
         @SCHEMANAME = object_schema_name(object_id(@TBL)),
         @TBLNAME    =        object_name(object_id(@TBL))

  IF @TABLE_ID IS NULL
  BEGIN
    PRINT @TBL + ' Is not a valid Object in the current database context. Compressions Estimates cannot be performed.'
  END
  IF NOT EXISTS(SELECT * FROM sys.objects OBJS  WHERE [TYPE] IN ('S','U') AND object_id = @TABLE_ID)
  BEGIN
    PRINT @TBL + ' Is not a Table Object, Compressions Estimates cannot be performed on this object.'
  END
    --#############################################################################################
    --Results Table
    --#############################################################################################
    IF OBJECT_ID('tempdb.[dbo].[#Results]') IS NOT NULL 
    DROP TABLE [dbo].[#Results] 

    CREATE TABLE [dbo].[#Results] ( 
    [ResultsID]                                           INT              IDENTITY(1,1)   NOT NULL,
    [CurrentCompression]                                  VARCHAR(30)                          NULL,
    [CompressionSetting]                                  VARCHAR(30)                          NULL,
    [CompressionRate] AS  CONVERT(Decimal(5,2), ([size_with_requested_compression_setting(KB)] * 1.0 / NULLIF([size_with_current_compression_setting(KB)],0)) * 100) ,
    [Savings] AS 100.0 - (CONVERT(Decimal(5,2), ([size_with_requested_compression_setting(KB)] * 1.0 / NULLIF([size_with_current_compression_setting(KB)],0)) * 100)),
    [object_name]                                         VARCHAR(128)                         NULL,
    [schema_name]                                         VARCHAR(128)                         NULL,
    [index_id]                                            INT                                  NULL,
    [index_name]                                          VARCHAR(128)                         NULL,
    [partition_number]                                    INT                                  NULL,
    [size_with_current_compression_setting(KB)]           INT                                  NULL,
    [size_with_requested_compression_setting(KB)]         INT                                  NULL,
    [sample_size_with_current_compression_setting(KB)]    INT                                  NULL,
    [sample_size_with_requested_compression_setting(KB)]  INT                                  NULL,
    [CompressionCommand] AS 'ALTER INDEX ' + quotename(ISNULL([index_name],'')) + ' ON ' + quotename([schema_name]) + '.' + quotename([object_name]) + ' REBUILD WITH ( DATA_COMPRESSION = ' + [CompressionSetting] + ' ) ;')

  IF @TABLE_ID IS NOT NULL
  BEGIN
    --#############################################################################################
    --Core work: call system proc
    --#############################################################################################
    INSERT INTO [#Results]([object_name],[schema_name],[index_id],[partition_number],[size_with_current_compression_setting(KB)],[size_with_requested_compression_setting(KB)],[sample_size_with_current_compression_setting(KB)],[sample_size_with_requested_compression_setting(KB)])
        EXEC sp_estimate_data_compression_savings @SCHEMANAME, @TBLNAME, NULL, NULL, 'ROW' ;
        UPDATE [#Results] SET [CompressionSetting]='ROW' WHERE [CompressionSetting] IS NULL

    INSERT INTO [#Results]([object_name],[schema_name],[index_id],[partition_number],[size_with_current_compression_setting(KB)],[size_with_requested_compression_setting(KB)],[sample_size_with_current_compression_setting(KB)],[sample_size_with_requested_compression_setting(KB)])
        EXEC sp_estimate_data_compression_savings @SCHEMANAME, @TBLNAME, NULL, NULL, 'PAGE' ;
        UPDATE [#Results] SET [CompressionSetting]='PAGE' WHERE [CompressionSetting] IS NULL
    END --IF

    ----#############################################################################################
    ----Dynamic Totals
    ----#############################################################################################
    SET IDENTITY_INSERT [#Results] ON
    INSERT INTO [#Results]([ResultsID],[CompressionSetting],[object_name],[schema_name],[index_id],[partition_number],[size_with_current_compression_setting(KB)],[size_with_requested_compression_setting(KB)],[sample_size_with_current_compression_setting(KB)],[sample_size_with_requested_compression_setting(KB)])
      SELECT 0,'---------------','----------','---',0,0,0,0,0,0
    
    INSERT INTO [#Results]([ResultsID],[CompressionSetting],[object_name],[schema_name],[index_id],[partition_number],[size_with_current_compression_setting(KB)],[size_with_requested_compression_setting(KB)],[sample_size_with_current_compression_setting(KB)],[sample_size_with_requested_compression_setting(KB)])
      SELECT -1,'Row Compression Total',@TBLNAME,@SCHEMANAME,0,0,SUM([size_with_current_compression_setting(KB)]),SUM([size_with_requested_compression_setting(KB)]),SUM([sample_size_with_current_compression_setting(KB)]),SUM([sample_size_with_requested_compression_setting(KB)])
      FROM [#Results] 
      WHERE [CompressionSetting] = 'ROW'
    
    INSERT INTO [#Results]([ResultsID],[CompressionSetting],[object_name],[schema_name],[index_id],[partition_number],[size_with_current_compression_setting(KB)],[size_with_requested_compression_setting(KB)],[sample_size_with_current_compression_setting(KB)],[sample_size_with_requested_compression_setting(KB)])
      SELECT -2,'Page Compression Total',@TBLNAME,@SCHEMANAME,0,0,SUM([size_with_current_compression_setting(KB)]),SUM([size_with_requested_compression_setting(KB)]),SUM([sample_size_with_current_compression_setting(KB)]),SUM([sample_size_with_requested_compression_setting(KB)])
      FROM [#Results] 
      WHERE [CompressionSetting] = 'PAGE'

    SET IDENTITY_INSERT [#Results] OFF


        --Update to have current compression settings.
    UPDATE r SET r.[CurrentCompression] = ISNULL(p.data_compression_desc,'')
    --SELECT r.[CurrentCompression],p.data_compression_desc
    FROM [#Results] r
    LEFT JOIN sys.partitions p 
    ON  r.schema_name = OBJECT_SCHEMA_NAME(p.object_id)
    AND r.object_name =  object_name(p.object_id)
    AND r.index_id = p.index_id
    --#############################################################################################
    --Index Names
    --#############################################################################################
    UPDATE MyTarget 
    SET MyTarget.[index_name] = MySource.name
    FROM [#Results] MyTarget
    INNER JOIN sys.indexes MySource ON MyTarget.index_id = MySource.index_id
    WHERE MySource.object_id =  @TABLE_ID
    --#############################################################################################
    --Return the Results
    --#############################################################################################
    SELECT * FROM [#Results] ORDER BY ResultsID
END --PROC

GO
--#################################################################################################
--Mark as a system object
EXECUTE sp_ms_marksystemobject  '[dbo].[sp_help_compression]'
--#################################################################################################
