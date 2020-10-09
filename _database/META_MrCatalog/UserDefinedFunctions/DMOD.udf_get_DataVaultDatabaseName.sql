SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- Author:      Emile Fraser
-- Create Date: 6 September 2019

	-- Gets the DatabaseName for DataVault for the Environment we are iin 

*/
-- Sample Execution Statement
--    Select [DMOD].[udf_get_DataVaultDatabaseName](18)
CREATE FUNCTION [DMOD].[udf_get_DataVaultDatabaseName](
    @LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    --DECLARE @LoadConfigID INT = 1
    DECLARE @DataVaultDatabaseName VARCHAR(MAX)
    DECLARE @SourceDataEntityID INT
    DECLARE @TargetDataEntityID INT
    DECLARE @SourceDatabaseID INT
    DECLARE @TargetDatabaseID INT
    DECLARE @SourceDatabasePurpose VARCHAR(MAX)
    DECLARE @TargetDatabasePurpose VARCHAR(MAX)
    DECLARE @SourceDatabaseEnvironmentID INT
    DECLARE @TargetDatabaseEnvironmentID INT
    
    ----Get Source and Target DataEntities
    SET @SourceDataEntityID = (SELECT DMOD.udf_get_LoadConfig_SourceDataEntityID(@LoadConfigID))
    SET @TargetDataEntityID = (SELECT DMOD.udf_get_LoadConfig_TargetDataEntityID(@LoadConfigID))
    --SELECT @SourceDataEntityID SourceDataEntityID , @TargetDataEntityID TargetDataEntityID

 

    ----Get Source and Target DBs of the Data Entities
    SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
    SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
    --SELECT @SourceDatabaseID SourceDatabaseID, @TargetDatabaseID TargetDatabaseID

 

    ----Get The DB Purpose of the DBS
    SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
    SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
    --SELECT @SourceDatabasePurpose AS SourceDatabasePurpose, @TargetDatabasePurpose AS TargetDatabasePurpose

 

    ----Get the DB Environment of the databases
    SET @SourceDatabaseEnvironmentID = (SELECT DetailID AS SourceEnvironment FROM TYPE.Generic_Detail WHERE DetailTypeCode = (SELECT DC.udf_get_DatabaseEnvironmentCode(@SourceDatabaseID)))
    SET @TargetDatabaseEnvironmentID = (SELECT DetailID AS TargetEnvironment FROM TYPE.Generic_Detail WHERE DetailTypeCode = (SELECT DC.udf_get_DatabaseEnvironmentCode(@TargetDatabaseID)))
    --SELECT @SourceDatabaseEnvironment SourceDatabaseEnvironment, @TargetDatabaseEnvironment TargetDatabaseEnviroment

 
		-- Try TargetFirst
        SET @DataVaultDatabaseName = 
        (
            SELECT
				db.DatabaseName 
			FROM 
				DataManager.DC.[Database] AS db
			INNER JOIN 
				DataManager.DC.[DatabasePurpose] AS dp
				ON dp.DatabasePurposeID = db.DatabasePurposeID
            WHERE 
				db.DatabaseEnvironmentTypeID = @TargetDatabaseEnvironmentID
			AND 
				dp.DatabasePurposeCode = 'DataVault'
		)
  
		-- Now Source
		IF(@DataVaultDatabaseName IS NULL)
		BEGIN        
			SET @DataVaultDatabaseName = 
			(
				SELECT
					db.DatabaseName 
				FROM 
					DataManager.DC.[Database] AS db
				INNER JOIN 
					DataManager.DC.[DatabasePurpose] AS dp
					ON dp.DatabasePurposeID = db.DatabasePurposeID
				WHERE 
					db.DatabaseEnvironmentTypeID = @SourceDatabaseEnvironmentID
				AND 
					dp.DatabasePurposeCode = 'DataVault'
			)
		END

		IF(@DataVaultDatabaseName IS NULL)
		BEGIN
			SET @DataVaultDatabaseName = 'FIX THIS!!!'
		END

	--select		@DataVaultDatabaseName
    RETURN QUOTENAME(@DataVaultDatabaseName)

 

END

GO
