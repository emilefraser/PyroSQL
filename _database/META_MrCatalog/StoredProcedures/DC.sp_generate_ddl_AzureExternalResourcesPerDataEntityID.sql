SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--EXEC [DC].[sp_generate_ddl_AzureExternalResourcesPerDataEntityID] 10399
CREATE PROCEDURE [DC].[sp_generate_ddl_AzureExternalResourcesPerDataEntityID] 
	@DataEntityID INT = 0
AS 
BEGIN
	DECLARE @TargetDataEntityID AS INT
	DECLARE @OutputSQL AS VARCHAR(MAX)
	DECLARE @DatabaseID AS INT

	SET @DatabaseID = (SELECT s.DatabaseID FROM DC.DataEntity AS de INNER JOIN DC.[Schema] AS s ON s.SchemaID = de.SchemaID WHERE de.DataEntityID = @DataEntityID)

	-- Firstly drop external table for the data entity
	SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Drop](@DataEntityID))
	PRINT (@OutputSQL)

	-- Recreate MasterKey Encryption
	SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption_Create]())
	PRINT(@OutputSQL)

	-- Then CREATE all External Scoped Credentials
	SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_DatabaseScopedCredential_Create](@DatabaseID))
	PRINT(@OutputSQL)


	-- Then CREATE all External Data Sources
	SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalDataSource_Create]('RDBMS', @DatabaseID))
	PRINT(@OutputSQL)

	-- THEN Create External Datatables
	SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](@DataEntityID))
	PRINT (@OutputSQL)
		
END

GO
