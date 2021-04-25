 CREATE DATABASE SCOPED CREDENTIAL dsc_CustomerTestBlobStorage
 WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
 SECRET = 'sig=vuKouVuYdHbz8o2%2FyOZ1QPxw8qEJftpTVbMlWsJEYvU%3D&st=2020-12-23T00%3A57%3A49Z&se=2021-12-23T00%3A57%3A49Z&sv=2017-04-17&sp=rwl&sr=b';

CREATE EXTERNAL DATA SOURCE eds_CustomerTestBlobStorage
WITH (	TYPE = BLOB_STORAGE, 
		LOCATION = 'https://acazsancustblob.blob.core.windows.net/test', 
		CREDENTIAL= dsc_CustomerTestBlobStorage	--> CREDENTIAL is not required if a blob storage is public!
);

EXEC sp_execute_remote
	@data_source_name  = N'eds_CustomerTestBlobStorage'
,	@stmt =			   = 'SELECT * FROM OPENROWSET(BULK ''arm_template.json'',
													DATASOURCE = ''



													eds_CustomerTestBlobStorage'


SELECT * FROM OPENROWSET(BULK 'arm_template.json',
							DATA_SOURCE = 'eds_CustomerTestBlobStorage',
							SINGLE_CLOB) AS arm_data



							sp_execute_remote [ @data_source_name = ] datasourcename  
[ , @stmt = ] statement  
[   
  { , [ @params = ] N'@parameter_name data_type [,...n ]' }   
     { , [ @param1 = ] 'value1' [ ,...n ] }  
]  