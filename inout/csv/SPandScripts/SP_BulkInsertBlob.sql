IF OBJECT_ID('dbo.SP_BulkInsertBlob','P') IS NOT NULL 
    DROP PROCEDURE dbo.SP_BulkInsertBlob 
GO

CREATE PROCEDURE dbo.SP_BulkInsertBlob
(
 @Delimited_FilePath VARCHAR(300), 
 @SAS_Token  VARCHAR(MAX),
 @Location  VARCHAR(MAX)
)
AS

/* 
    Parameters and usage 
	
	@Delimited_FilePath - The name of the CSV File that we uploaded in the blob container
	
	@SAS_Token - The Shared Access Token which used to access the blob from the private container -The SAS key value might begin with a '?' (question mark). When you use the SAS key, you must remove the leading '?'. Otherwise, your efforts might be blocked.
	
	@Location - The URL of the Azure Storage account along with the Container
	
	
	
	
*/ 
BEGIN
 
SET NOCOUNT ON

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
 BULK INSERT userdetails
 FROM ''' + @Delimited_FilePath + '''
 WITH ( DATA_SOURCE = ''' + @ExtlDS + ''',
 Format=''CSV''
 );
 ';
 
 --PRINT @BulkInsSQL
 EXEC (@BulkInsSQL);
 
 END TRY
 BEGIN CATCH
 
 PRINT @@ERROR
 END CATCH
 END;