/* 
csv file:
1,JAYENDRAN,24
2,Testing,25
*/

-- create master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0me!nfo';

Creating database scoped credential
CREATE DATABASE SCOPED CREDENTIAL credential_name   WITH IDENTITY = 'identity_name'    [ , SECRET = 'secret' ] 

CREATE DATABASE SCOPED CREDENTIAL MyCredentials WITH IDENTITY = 'SHARED ACCESS SIGNATURE',SECRET = 'QLYMgmSXMklt%2FI1U6DcVrQixnlU5Sgbtk1qDRakUBGs%3D';
Note: The SAS key value might begin with a ‘?’ (question mark). When you use the SAS key, you must remove the leading ‘?’. Otherwise, your efforts might be blocked.


Creating external data source
Creating an external data source helps us to refer our Azure blob storage container, specify the Azure blob storage URI and a database scoped credential that contains your Azure storage account key.

Syntax:

CREATE EXTERNAL DATA SOURCE data_source_name 
 WITH ( 
 TYPE = BLOB_STORAGE, 
 LOCATION = 'https://storage_account_name.blob.core.windows.net/container_name'
 [, CREDENTIAL = credential_name ]
 )
Example:

CREATE EXTERNAL DATA SOURCE MyAzureStorage WITH (
 TYPE = BLOB_STORAGE,
 LOCATION = 'https://myaccount.blob.core.windows.net/testingcontainer',
 CREDENTIAL = MyCredentials
);



BULK INSERT 
 [ database_name . [ schema_name ] . | schema_name . ] [ table_name | view_name ] 
 FROM 'data_file' 
 [ WITH 
 ( 
 [ [ , ] BATCHSIZE = batch_size ] 
 [ [ , ] CHECK_CONSTRAINTS ] 
 [ [ , ] CODEPAGE = { 'ACP' | 'OEM' | 'RAW' | 'code_page' } ] 
 [ [ , ] DATAFILETYPE = 
 { 'char' | 'native'| 'widechar' | 'widenative' } ] 
 [ [ , ] DATASOURCE = 'data_source_name' ]
 [ [ , ] ERRORFILE = 'file_name' ]
 [ [ , ] ERRORFILE_DATA_SOURCE = 'data_source_name' ] 
 [ [ , ] FIRSTROW = first_row ] 
 [ [ , ] FIRE_TRIGGERS ] 
 [ [ , ] FORMATFILE_DATASOURCE = 'data_source_name' ]
 [ [ , ] KEEPIDENTITY ] 
 [ [ , ] KEEPNULLS ] 
 [ [ , ] KILOBYTES_PER_BATCH = kilobytes_per_batch ] 
 [ [ , ] LASTROW = last_row ] 
 [ [ , ] MAXERRORS = max_errors ] 
 [ [ , ] ORDER ( { column [ ASC | DESC ] } [ ,...n ] ) ] 
 [ [ , ] ROWS_PER_BATCH = rows_per_batch ] 
 [ [ , ] ROWTERMINATOR = 'row_terminator' ] 
 [ [ , ] TABLOCK ] 
 
 -- input file format options
 [ [ , ] FORMAT = 'CSV' ]
 [ [ , ] FIELDQUOTE = 'quote_characters']
 [ [ , ] FORMATFILE = 'format_file_path' ] 
 [ [ , ] FIELDTERMINATOR = 'field_terminator' ] 
 [ [ , ] ROWTERMINATOR = 'row_terminator' ] 
 )]
Example:

CREATE table userdetails (id int,name varchar(max),age int)


BULK INSERT Sales.Invoices
FROM 'inv-2017-12-08.csv'
WITH (DATA_SOURCE = 'MyAzureStorage');


CREATE table userdetails (id int,name varchar(max),age int)
Now we will see the Stored Procedure code,

CREATE PROCEDURE dbo.BulkInsertBlob
(
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
 BULK INSERT userdetails
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


 exec BulkInsertBlob 'inputblob.csv','st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D','https://testingstorageaccount.blob.core.windows.net/testing'
The parameters we are using are:

​Storage Account Name: https://testingstorageaccount.blob.core.windows.net/
Container Name: testing
SAS Token: st=2018-10-21T14%3A32%3A16Z&se=2018-10-22T14%3A32%3A16Z&sp=rl&sv=2018-03-28&sr=b&sig=5YCuPCTVTt826ilyVsLBrKarPNg5sWUyrN7bMQ5fIhc%3D
FileName: inputblob.csv