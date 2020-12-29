CREATE EXTERNAL DATA SOURCE AcAzDevelopmentBlob
WITH ( TYPE = BLOB_STORAGE, LOCATION = 'https://acazsancustblob.blob.core.windows.net');

DROP DATABASE SCOPED CREDENTIAL AcAzDevelopmentCredential

-- --?sv=2019-12-12&st=2020-12-29T22%3A07%3A20Z&se=2021-12-30T22%3A07%3A00Z&sr=c&sp=racwl&sig=XsA9%2FUfdURGQV2ZX3GEvP82HxUMAewpURzo4hySlcH4%3D
CREATE DATABASE SCOPED CREDENTIAL AcAzDevelopmentCredential
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '?sv=2019-12-12&ss=btqf&srt=sco&st=2020-12-29T18%3A27%3A25Z&se=2021-12-30T18%3A27%3A00Z&sp=rl&sig=DpQbgJWXRgI300lios5cq2%2BsESpr%2FOZcxZqKQefi4xk%3D'

CREATE DATABASE SCOPED CREDENTIAL AcAzDevelopmentCredential
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sv=2019-12-12&ss=btqf&srt=sco&st=2020-12-29T18%3A27%3A25Z&se=2021-12-30T18%3A27%3A00Z&sp=rl&sig=DpQbgJWXRgI300lios5cq2%2BsESpr%2FOZcxZqKQefi4xk%3D'

CREATE DATABASE SCOPED CREDENTIAL AcAzDevelopmentCredential
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '?sv=2019-12-12&st=2020-12-29T18%3A38%3A14Z&se=2021-12-30T18%3A38%3A00Z&sr=b&sp=r&sig=G3I8YFBOR5p2EAB5up5nsgWjGsMt%2BKYNTbMvPeF102w%3D'
 
CREATE DATABASE SCOPED CREDENTIAL AcAzDevelopmentCredential
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'UM0hh6de9+7+X+jVLaY7xj9CS7FFTVcQ/+mQ0bwnyMGmkUYFHrv9FFDx10q9DyO7SsojhtEwYY0zCl2xvHonyA=='

DROP EXTERNAL DATA SOURCE AcAzDevelopmentDataSource

CREATE EXTERNAL DATA SOURCE AcAzDevelopmentDataSource
WITH ( 
	TYPE = BLOB_STORAGE,
    LOCATION = 'https://acazdevelopmentblob.blob.core.windows.net',
    CREDENTIAL= AcAzDevelopmentCredential
);

	   
SELECT * FROM OPENROWSET (
	BULK 'connect/connectionstrings.csv'
,	DATA_SOURCE = 'AcAzDevelopmentDataSource'
,	SINGLE_CLOB
)  AS tst
	
SELECT * FROM OPENROWSET (
	BULK 'connect/input.csv'
,	DATA_SOURCE = 'AcAzDevelopmentDataSource'
,	SINGLE_CLOB
)  AS tst
  
  SELECT * FROM OPENROWSET (
	BULK 'connect/product.csv'
,	DATA_SOURCE = 'AcAzDevelopmentDataSource'
,	SINGLE_CLOB
)  AS tst


SELECT * FROM OPENROWSET (
	BULK 'connect/connectionstrings.csv'
,	DATA_SOURCE = 'AcAzDevelopmentDataSource'
,	SINGLE_BLOB
)  AS tst
	
   
SELECT * FROM OPENROWSET (
	BULK 'connect/connectionstrings.csv'
,	DATA_SOURCE = 'AcAzDevelopmentDataSource'
,	SINGLE_NCLOB
)  AS tst

SELECT *
FROM 'connect/connectionstrings.csv'
WITH
(
   DATA_SOURCE = 'AcAzDevelopmentDataSource',
   FORMAT = 'CSV',
   CODEPAGE = 65001,
   FIRSTROW = 2,
   TABLOCK
);


BULK INSERT [BULKUPLOADTABLE]
FROM 'MYDATA/SAMPLEDATA.TXT'
WITH
(
   DATA_SOURCE = 'MYDATASOURCE',
   FORMAT = 'CSV',
   CODEPAGE = 65001,
   FIRSTROW = 2,
   TABLOCK
);