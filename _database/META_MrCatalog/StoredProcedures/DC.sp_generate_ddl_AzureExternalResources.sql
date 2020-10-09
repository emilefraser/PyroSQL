SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--EXEC [DC].[sp_generate_ddl_AzureExternalResources] 8
CREATE PROCEDURE [DC].[sp_generate_ddl_AzureExternalResources] 
	@ServerTypeID INT = 8
AS 
BEGIN
	DECLARE @TargetDataEntityID AS INT
	DECLARE @OutputSQL AS VARCHAR(MAX)
	DECLARE @ServerTypeCode AS VARCHAR(100)
	DECLARE @DataEntityID AS INT
	DECLARE @DatabaseID AS INT
	DECLARE @ExcludedSchema VARCHAR(MAX) = 'INTEGRATION' -- TODO: To be removed later 

	SET @ServerTypeCode = (SELECT ServerTypeCode FROM [DC].[ServerType] WHERE ServerTypeID = @ServerTypeID)

	DECLARE database_cursor CURSOR FOR   
	SELECT d.DatabaseID
	FROM DC.[Server] AS s
	INNER JOIN [DC].[ServerType] AS st
	ON s.ServerTypeID = st.ServerTypeID
	INNER JOIN DC.DatabaseInstance AS di
	ON di.ServerID = s.ServerID
	INNER JOIN [DC].[Database] AS d
	ON d.DatabaseInstanceID = di.DatabaseInstanceID
	WHERE st.ServerTypeCode = @ServerTypeCode
	AND d.[DatabaseName] = 'DEV_ODS_EMS' -- TODO: To be removed later, create seperate stored proc with dataentityid
	 
	OPEN database_cursor  
  
	FETCH NEXT FROM database_cursor   
	INTO @DatabaseID
  
	
WHILE @@FETCH_STATUS = 0  
BEGIN  

			DECLARE target_dataentityid CURSOR FOR   
			SELECT DISTINCT DataEntityID
			FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD]
			WHERE DatabaseID = @DatabaseID
			AND SchemaName != @ExcludedSchema

			OPEN target_dataentityid  

			FETCH NEXT FROM target_dataentityid   
			INTO @DataEntityID

			WHILE @@FETCH_STATUS = 0  
			BEGIN	

				-- Firstly Drop all External Data Tables
				SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Drop](@DataEntityID))
				PRINT (@OutputSQL)

				FETCH NEXT FROM target_dataentityid   
				INTO @DataEntityID

			END   
			CLOSE target_dataentityid;  
			DEALLOCATE target_dataentityid;  

			-- Then Drop all External Data Sources
			SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalDataSource_Drop]('RDBMS', @DatabaseID))
			PRINT(@OutputSQL)

			-- Then Drop all External Scoped Credentials
			SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_DatabaseScopedCredential_Drop](@DatabaseID))
			PRINT(@OutputSQL)
			

	FETCH NEXT FROM database_cursor   
	INTO @DatabaseID

END   
CLOSE database_cursor;  
DEALLOCATE database_cursor;  



-- Then Drop MasterKey Encryption
SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption_Drop]())
PRINT(@OutputSQL)

-- Recreate MasterKey Encryption
SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_MasterKeyEncryption_Create]())
PRINT(@OutputSQL)

-- Rerun Database Cursor
	DECLARE database_cursor CURSOR FOR   
	SELECT d.DatabaseID
	FROM DC.[Server] AS s
	INNER JOIN [DC].[ServerType] AS st
	ON s.ServerTypeID = st.ServerTypeID
	INNER JOIN DC.DatabaseInstance AS di
	ON di.ServerID = s.ServerID
	INNER JOIN [DC].[Database] AS d
	ON d.DatabaseInstanceID = di.DatabaseInstanceID
	WHERE st.ServerTypeCode = @ServerTypeCode
	AND d.[DatabaseName] = 'DEV_ODS_EMS'

	OPEN database_cursor  
  
	FETCH NEXT FROM database_cursor   
	INTO @DatabaseID
  
	
WHILE @@FETCH_STATUS = 0  
BEGIN  
			-- Then CREATE all External Scoped Credentials
			SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_DatabaseScopedCredential_Create](@DatabaseID))
			PRINT(@OutputSQL)


			-- Then CREATE all External Data Sources
			SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalDataSource_Create]('RDBMS', @DatabaseID))
			PRINT(@OutputSQL)


			DECLARE target_dataentityid CURSOR FOR   
			SELECT DISTINCT DataEntityID
			FROM [DC].[vw_rpt_DatabaseFieldDetailDMOD]
			WHERE DatabaseID = @DatabaseID
			AND SchemaName != @ExcludedSchema

			OPEN target_dataentityid  

			FETCH NEXT FROM target_dataentityid   
			INTO @DataEntityID

			WHILE @@FETCH_STATUS = 0  
			BEGIN	

				-- THEN Create External Datatables
				SET @OutputSQL = (SELECT [DC].[udf_generate_DDL_AZSQL_ExternalTable_Create](@DataEntityID))
				PRINT (@OutputSQL)

				FETCH NEXT FROM target_dataentityid   
				INTO @DataEntityID

			END   
			CLOSE target_dataentityid;  
			DEALLOCATE target_dataentityid;  

	FETCH NEXT FROM database_cursor   
	INTO @DatabaseID

END   
CLOSE database_cursor;  
DEALLOCATE database_cursor;  





END

GO
