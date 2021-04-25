SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[BulkInsertBlob]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[BulkInsertBlob] AS' 
END
GO
/*
Here the Stored procedure have 3 parameters 

Delimited_FilePath - The name of the CSV File that already in the blob container
SAS_Token - For accessing any blob within the container (Private container) we need a SAS token. (You can refer here on how to generate the SAS token)
Location - The URL of the Azure Storage Account along with the container

exec inout.BulkInsertBlob 'inputblob.csv','st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D','https://testingstorageaccount.blob.core.windows.net/testing'
The parameters we are using are:

?Storage Account Name: https://testingstorageaccount.blob.core.windows.net/
Container Name: testing
SAS Token: st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D
FileName: inputblob.csv
*/


ALTER     PROCEDURE [inout].[BulkInsertBlob]
(
 @SchemaName SYSNAME ,
 @Tablename SYSNAME,
 @Delimited_FilePath VARCHAR(300), 
 @SAS_Token  VARCHAR(MAX),
 @Location  VARCHAR(MAX)
)
AS
BEGIN
 
BEGIN TRY
 
 --Create new External Data Source & Credential for the Blob, custom for the current upload
 DECLARE @CrtDSSQL NVARCHAR(MAX), @DrpDSSQL NVARCHAR(MAX), @ExtlDS SYSNAME, @DBCred SYSNAME, @BulkInsSQL NVARCHAR(MAX) ;
 
 SELECT @ExtlDS = 'MyAzureBlobStorage'
 SELECT @DBCred = 'MyAzureBlobStorageCredential'
 
 SET @DrpDSSQL = N'
 IF EXISTS ( SELECT 1 FROM sys.external_data_sources WHERE Name = ''' + @ExtlDS + ''' )
 BEGIN
 DROP EXTERNAL DATA SOURCE ' + @ExtlDS + ' ;
 END;
 
 IF EXISTS ( SELECT 1 FROM sys.database_scoped_credentials WHERE Name = ''' + @DBCred + ''' )
 BEGIN
 DROP DATABASE SCOPED CREDENTIAL ' + @DBCred + ';
 END;
 ';
 
 SET @CrtDSSQL = @DrpDSSQL + N'
 CREATE DATABASE SCOPED CREDENTIAL ' + @DBCred + '
 WITH IDENTITY = ''SHARED ACCESS SIGNATURE'',
 SECRET = ''' + @SAS_Token + ''';
 
 CREATE EXTERNAL DATA SOURCE ' + @ExtlDS + '
 WITH (
 TYPE = BLOB_STORAGE,
 LOCATION = ''' + @Location + ''' ,
 CREDENTIAL = ' + @DBCred + '
 );
 ';
 
 --PRINT @CrtDSSQL
 EXEC (@CrtDSSQL);
 
  
 --Bulk Insert the data from CSV file into interim table
 SET @BulkInsSQL = N'
 BULK INSERT ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
 FROM ''' + @Delimited_FilePath + '''
 WITH ( DATA_SOURCE = ''' + @ExtlDS + ''',
 Format=''CSV'',
 FIELDTERMINATOR = '','',
 --ROWTERMINATOR = ''\n''
 ROWTERMINATOR = ''0x0a''
 );
 ';
 
 --PRINT @BulkInsSQL
 EXEC (@BulkInsSQL);
 
 END TRY
 BEGIN CATCH
 
 PRINT @@ERROR
 END CATCH
 END;
GO
