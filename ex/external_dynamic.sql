-- Procedure to showcase external connections via sharded query
CREATE OR ALTER PROCEDURE ex.ExecuteRemoteStatement
@Scoped


-- Test if scoped cred exists
IF EXISTS (
    SELECT 1 FROM sys.database_scoped_credentials
-- TODO: Move to own stored proc
CREATE DATABASE SCOPED CREDENTIAL dsc_pyromaniac 
WITH IDENTITY = 'pyromaniac',
SECRET = '105022_Alpha';

CREATE EXTERNAL DATA SOURCE eds_master 
WITH (
		TYPE = RDBMS,
		LOCATION = 'acazmssql01.database.windows.net',
		DATABASE_NAME = 'master',
		CREDENTIAL = dsc_pyromaniac
) ;

EXEC sp_execute_remote
		N'eds_masterdb',
		N'Select * FROM sys.views'