SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inout].[FullExternalDataSourceSetup]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [inout].[FullExternalDataSourceSetup] AS' 
END
GO
ALTER PROCEDURE [inout].[FullExternalDataSourceSetup]
AS
select ''
/*
CREATE MASTER KEY ENCRYPTION
    BY PASSWORD = '105022_Alpha'

CREATE DATABASE SCOPED CREDENTIAL TestScopedSecurity 
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET =
    'sv=2020-04-08&st=2021-04-24T21%3A01%3A51Z&se=2021-04-25T21%3A01%3A51Z&sr=c&sp=rl&sig=eEt9QhzDz4jXGau%2BUC6WpX%2BY1JPP%2Bub4klmb%2FSVpKtI%3D';
	

CREATE EXTERNAL DATA SOURCE TestExternalDatsource
    WITH  (
        TYPE = BLOB_STORAGE,
        LOCATION = 'https://acazdevelopmentblob.blob.core.windows.net/connect',
        CREDENTIAL = TestScopedSecurity
    );
	
	
 SELECT * FROM OPENROWSET(
   BULK 'input.csv',   
   DATA_SOURCE = 'TestExternalDatsource',
   SINGLE_CLOB 
   ) AS DataFile;  
   
*/
GO
