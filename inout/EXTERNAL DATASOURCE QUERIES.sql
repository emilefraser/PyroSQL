IF NOT EXISTS (
	SELECT * 
	FROM sys.external_data_sources 
	WHERE name = 'AzureBlobStorage'
)
CREATE EXTERNAL DATA SOURCE AzureBlobStorage
WITH ( TYPE = BLOB_STORAGE, LOCATION = 'https://myblob.blob.core.windows.net');

--BULK INSERT from Blob Storage
BULK INSERT [dbo].[Document]
FROM 'files/Documents.csv'
WITH (DATA_SOURCE = 'AzureBlobStorage', KEEPIDENTITY, FIELDTERMINATOR = '|', FIRSTROW = 2, ROWTERMINATOR = '\n', KEEPNULLS);


------------------

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'put some strong password here';
GO
CREATE DATABASE SCOPED CREDENTIAL SynapseSqlCredential
	WITH IDENTITY = '<synapse sql username>', SECRET = '<synapse sql password>';  
GO
CREATE EXTERNAL DATA SOURCE SynapseSqlDataSource
WITH  (
	TYPE = RDBMS,
	LOCATION = '<synapse workspace>-ondemand.sql.azuresynapse.net',
	DATABASE_NAME = 'SampleDB',
	CREDENTIAL = SynapseSqlCredential
);
GO

----------------------

CREATE MASTER KEY ENCRYPTION BY PASSWORD='Password';

CREATE DATABASE SCOPED CREDENTIAL AppCredential 
WITH IDENTITY = 'username', SECRET = 'Password';

CREATE EXTERNAL DATA SOURCE RemoteReferenceData
WITH
(
TYPE=RDBMS,
LOCATION='tcp:servername.public.virtualnetwork.database.windows.net,3342',
DATABASE_NAME='DatabaseName',
CREDENTIAL= AppCredential
);

CREATE EXTERNAL TABLE Table1
(ID int )
WITH
(
DATA_SOURCE = RemoteReferenceData
);

EXEC sp_execute_remote N'RemoteReferenceData', N'INSERT INTO Table1 values(2)'


---------

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<password>';
CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH IDENTITY = 'user', Secret = '<azure_storage_account_key>';

CREATE EXTERNAL DATA SOURCE AzureStorage with (
 TYPE = HADOOP,
 LOCATION ='wasbs://<blob_container_name>@<azure_storage_account_name>.blob.core.windows.net',
 CREDENTIAL = AzureStorageCredential
 );

 CREATE EXTERNAL FILE FORMAT TextFileFormat
WITH (
       FORMAT_TYPE = DELIMITEDTEXT,
       FORMAT_OPTIONS (
         FIELD_TERMINATOR ='|',
         USE_TYPE_DEFAULT = TRUE
       )
);

CREATE EXTERNAL TABLE [dbo].[CarSensor_Data] (
        [SensorKey] int NOT NULL,
        [CustomerKey] int NOT NULL,
        [GeographyKey] int NULL,
        [Speed] float NOT NULL,
        [YearMeasured] int NOT NULL
)
WITH (LOCATION='/<path>/',
        DATA_SOURCE = AzureStorage,
        FILE_FORMAT = TextFileFormat
);

-------------


-- MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'S0me!nfo';  


--Create a database scoped credential for Azure blob storage.

-- IDENTITY: any string (this is not used for authentication to Azure storage).  
-- SECRET: your Azure storage account key.  
CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH IDENTITY = 'user', Secret = '<azure_storage_account_key>';


--Create an external data source with CREATE EXTERNAL DATA SOURCE..
-- LOCATION:  Azure account storage account name and blob container name.  
-- CREDENTIAL: The database scoped credential created above.  
CREATE EXTERNAL DATA SOURCE AzureStorage with (  
      TYPE = HADOOP,
      LOCATION ='wasbs://<blob_container_name>@<azure_storage_account_name>.blob.core.windows.net',  
      CREDENTIAL = AzureStorageCredential  
);  


-- Create an external file format with CREATE EXTERNAL FILE FORMAT.
-- FORMAT TYPE: Type of format in Hadoop (DELIMITEDTEXT,  RCFILE, ORC, PARQUET).
CREATE EXTERNAL FILE FORMAT TextFileFormat WITH (  
      FORMAT_TYPE = DELIMITEDTEXT,
      FORMAT_OPTIONS (FIELD_TERMINATOR ='|',
            USE_TYPE_DEFAULT = TRUE))  

--Create an external table pointing to data stored in Azure storage with CREATE EXTERNAL TABLE. In this example, the external data contains car sensor data.
-- LOCATION: path to file or directory that contains the data (relative to HDFS root).  
CREATE EXTERNAL TABLE [dbo].[CarSensor_Data] (  
      [SensorKey] int NOT NULL,
      [CustomerKey] int NOT NULL,
      [GeographyKey] int NULL,
      [Speed] float NOT NULL,
      [YearMeasured] int NOT NULL  
)  
WITH (LOCATION='/Demo/',
      DATA_SOURCE = AzureStorage,  
      FILE_FORMAT = TextFileFormat  
);  


--Create statistics on an external table.
CREATE STATISTICS StatsForSensors on CarSensor_Data(CustomerKey, Speed)  

--------------
-- Enable INSERT into external table  
sp_configure 'allow polybase export', 1;  
reconfigure  
  
-- Create an external table.
CREATE EXTERNAL TABLE [dbo].[FastCustomers2009] (  
      [FirstName] char(25) NOT NULL,
      [LastName] char(25) NOT NULL,
      [YearlyIncome] float NULL,
      [MaritalStatus] char(1) NOT NULL  
)  
WITH (  
      LOCATION='/old_data/2009/customerdata',  
      DATA_SOURCE = HadoopHDP2,  
      FILE_FORMAT = TextFileFormat,  
      REJECT_TYPE = VALUE,  
      REJECT_VALUE = 0  
);  

-- Export data: Move old data to Hadoop while keeping it query-able via an external table.  
INSERT INTO dbo.FastCustomer2009  
SELECT T.* FROM Insured_Customers T1 JOIN CarSensor_Data T2  
ON (T1.CustomerKey = T2.CustomerKey)  
WHERE T2.YearMeasured = 2009 and T2.Speed > 40;

---------------

CREATE EXTERNAL DATA SOURCE <data_source_name>
WITH
  ( [ LOCATION = '<prefix>://<path>[:<port>]' ]
    [ [ , ] CONNECTION_OPTIONS = '<name_value_pairs>']
    [ [ , ] CREDENTIAL = <credential_name> ]
    [ [ , ] PUSHDOWN = { ON | OFF } ]
    [ [ , ] TYPE = { HADOOP | BLOB_STORAGE } ]
    [ [ , ] RESOURCE_MANAGER_LOCATION = '<resource_manager>[:<port>]' )
[ ; ]

LOCATION = '<prefix>://<path[:port]>'
Provides the connectivity protocol and path to the external data source.

LOCATION = '<PREFIX>://<PATH[:PORT]>'
External Data Source	Location prefix	Location path	Supported locations by product / service
Cloudera or Hortonworks	hdfs	<Namenode>[:port]	Starting with SQL Server 2016 (13.x)
Azure Storage account(V2)	wasb[s]	<container>@<storage_account>.blob.core.windows.net	Starting with SQL Server 2016 (13.x) Hierarchical Namespace not supported
SQL Server	sqlserver	<server_name>[\<instance_name>][:port]	Starting with SQL Server 2019 (15.x)
Oracle	oracle	<server_name>[:port]	Starting with SQL Server 2019 (15.x)
Teradata	teradata	<server_name>[:port]	Starting with SQL Server 2019 (15.x)
MongoDB or CosmosDB	mongodb	<server_name>[:port]	Starting with SQL Server 2019 (15.x)
ODBC	odbc	<server_name>[:port]	Starting with SQL Server 2019 (15.x) - Windows only
Bulk Operations	https	<storage_account>.blob.core.windows.net/<container>	Starting with SQL Server 2017 (14.x)
Edge Hub	edgehub	Not Applicable	EdgeHub is always local to the instance of Azure SQL Edge. As such there is no need to specify a path or port value. Only available in Azure SQL Edge.
Kafka	kafka	<Kafka IP Address>[:port]	Only available in Azure SQL Edge.


Location path:

<Namenode> = the machine name, name service URI, or IP address of the Namenode in the Hadoop cluster. PolyBase must resolve any DNS names used by the Hadoop cluster.
port = The port that the external data source is listening on. In Hadoop, the port can be found using the fs.defaultFS configuration parameter. The default is 8020.
<container> = the container of the storage account holding the data. Root containers are read-only, data can't be written back to the container.
<storage_account> = the storage account name of the Azure resource.
<server_name> = the host name.
<instance_name> = the name of the SQL Server named instance. Used if you have SQL Server Browser Service running on the target instance.



REDENTIAL = credential_name
Specifies a database-scoped credential for authenticating to the external data source.

Additional notes and guidance when creating a credential:

CREDENTIAL is only required if the data has been secured. CREDENTIAL isn't required for data sets that allow anonymous access.
When TYPE = BLOB_STORAGE the credential must be created using SHARED ACCESS SIGNATURE as the identity. Furthermore, the SAS token should be configured as follows:
Exclude the leading ? when configured as the secret
Have at least read permission on the file that should be loaded (for example srt=o&sp=r)
Use a valid expiration period (all dates are in UTC time).


TYPE = [ HADOOP | BLOB_STORAGE ]
Specifies the type of the external data source being configured. This parameter isn't always required.

Use HADOOP when the external data source is Cloudera, Hortonworks, or an Azure Storage account.
Use BLOB_STORAGE when executing bulk operations from Azure Storage account using BULK INSERT, or OPENROWSET with SQL Server 2017 (14.x).
 Important

Do not set TYPE if using any other external data source.

For an example of using TYPE = HADOOP to load data from an Azure Storage account, see Create external data source to access data in Azure Storage using the wasb:// interface


------------

-- Create a database master key if one does not already exist, using your own password. This key is used to encrypt the credential secret in next step.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '105022_Alpha' ;

-- Create a database scoped credential with Azure storage account key as the secret.
CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH
  IDENTITY = '<my_account>' ,
  SECRET = '<azure_storage_account_key>' ;

-- Create an external data source with CREDENTIAL option.
CREATE EXTERNAL DATA SOURCE MyAzureStorage
WITH
  ( LOCATION = 'wasbs://daily@logs.blob.core.windows.net/' ,
    CREDENTIAL = AzureStorageCredential ,
    TYPE = HADOOP
  ) ;






  4B0SWbAdenN9j4lDC1XDMcQqqptPBlC0G38B+Eei0as8t0mLZwVY6xqlAnj6+fzaB9lnXtEoh0D8Az+ulGFNcQ==



  ---------

  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '105022_Alpha';

 CREATE EXTERNAL DATA SOURCE MyAzureBlobStorage
 WITH ( TYPE = BLOB_STORAGE, LOCATION = 'https://acazsancustblob.blob.core.windows.net');

 CREATE DATABASE SCOPED CREDENTIAL MyAzureBlobStorageCredential
 WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
 SECRET = 'sv=2019-12-12&ss=btqf&srt=sco&st=2020-12-25T21%3A07%3A30Z&se=2021-12-26T21%3A07%3A00Z&sp=rl&sig=%2BWWj6OlMu8SdErRvfNjEzw0doyicKvWPWkZmEuavo3Y%3D';

 CREATE EXTERNAL DATA SOURCE MyAzureBlobStorage
 WITH ( TYPE = BLOB_STORAGE,
       LOCATION = 'https://acazsancustblob.blob.core.windows.net',
       CREDENTIAL= MyAzureBlobStorageCredential);


SELECT * FROM OPENROWSET(BULK 'test/input.csv',
							DATA_SOURCE = 'MyAzureBlobStorage',
							SINGLE_CLOB) AS arm_data


SELECT * FROM OPENROWSET (
	BULK 'test/input.csv',
	 DATA_SOURCE = 'AzureBlobStorage', FIELDTERMINATOR = ',', FIRSTROW = 2, ROWTERMINATOR = '\n', KEEPNULLS
) AS tst


SELECT * FROM OPENROWSET (
	BULK 'test/input.csv',
	DATA_SOURCE = 'MyAzureBlobStorage', FORMAT='CSV') AS tst

CREATE TABLE dbo.Testy (id varchar(100), val varchar(100))

BULK INSERT dbo.Testy 
FROM 'test/input.csv'
WITH (	DATA_SOURCE = 'MyAzureBlobStorage',
		FORMAT='CSV', CODEPAGE = 65001, --UTF-8 encoding
		FIRSTROW=2,
                ROWTERMINATOR = '0x0a',
		TABLOCK); 