/********************************************************************************
*	Note: You can export file and create format file using bcp out command:
*
*>bcp "SELECT Name, Color, Price, Size, Quantity, Data, Tags FROM Product" queryout product.dat -d ProductCatalog -T
*
********************************************************************************/

/********************************************************************************
*								SETUP											*
********************************************************************************/

-- Create master key that will encrypt credentials
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'some strong password';

-- Create credential with Azure Blob SAS
CREATE DATABASE SCOPED CREDENTIAL MyAzureBlobStorageCredential 
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sv=2015-12-11&ss=b&srt=sco&sp=rwac&se=2017-02-01T00:55:34Z&st=2016-12-29T16:55:34Z&spr=https&sig=copyFromAzurePortal';

-- Create external data source with with the roow URL of the Blob storage Account and associated credential.
CREATE EXTERNAL DATA SOURCE MyAzureBlobStorage
WITH (	TYPE = BLOB_STORAGE, 
		LOCATION = 'https://myazureblobstorage.blob.core.windows.net', 
		CREDENTIAL= MyAzureBlobStorageCredential);

/********************************************************************************
*					CREATE DESTINATION TABLE (if not exists)					*
*********************************************************************************/

DROP TABLE IF EXISTS Product;
GO

CREATE TABLE dbo.Product(
	Name nvarchar(50) NOT NULL,
	Color nvarchar(15) NULL,
	Price money NOT NULL,
	Size nvarchar(5) NULL,
	Quantity int NULL,
	Data nvarchar(4000) NULL,
	Tags nvarchar(4000) NULL,
	INDEX cci CLUSTERED COLUMNSTORE
)
GO

/********************************************************************************
*								LOAD											*
*********************************************************************************/

-- INSERT CSV file into Product table
BULK INSERT Product
FROM 'data/product.csv'
WITH (	DATA_SOURCE = 'MyAzureBlobStorage',
		FORMAT='CSV', CODEPAGE = 65001, --UTF-8 encoding
		FIRSTROW=2,
		TABLOCK); 

-- INSERT file exported using bcp.exe into Product table
BULK INSERT Product
FROM 'data/product.bcp'
WITH (	DATA_SOURCE = 'MyAzureBlobStorage',
		FORMATFILE='data/product.fmt',
		FORMATFILE_DATA_SOURCE = 'MyAzureBlobStorage',
		TABLOCK); 

-- Read rows from product.dat file using format file and insert it into Product table
INSERT INTO Product WITH (TABLOCK) (Name, Color, Price, Size, Quantity, Data, Tags) 
SELECT Name, Color, Price, Size, Quantity, Data, Tags
FROM OPENROWSET(BULK 'data/product.bcp',
				DATA_SOURCE = 'MyAzureBlobStorage',
				FORMATFILE='data/product.fmt',
				FORMATFILE_DATA_SOURCE = 'MyAzureBlobStorage') as products; 

-- Query remote file 
SELECT Color, count(*)
FROM OPENROWSET(BULK 'data/product.bcp',
				DATA_SOURCE = 'MyAzureBlobStorage',
				FORMATFILE='data/product.fmt',
				FORMATFILE_DATA_SOURCE = 'MyAzureBlobStorage') as data
GROUP BY Color;