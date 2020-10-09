SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

--!~ Last CreateDT replacement for Incremental Loads
			SELECT	@LastCreateDT = ISNULL(MAX([CREATEDDATETIME1]),'1900-01-01')
			FROM	[DEV_DataVault].[raw].[SAT_Customer_EMS_LVD]
-- Last CreateDT replacement for Incremental Loads ~!

-- Sample Execution Statement
--Select [DMOD].[udf_get_DataVaultEntityType_CreatedDT_Last](25) 
*/
CREATE     FUNCTION [DMOD].[udf_get_DataVaultEntityType_CreatedDT_Last](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	-- :DEBUG:
	--		DECLARE @LoadConfigID INT = 25
	-- :DEBUG:

	DECLARE @ReturnName VARCHAR(MAX)
	DECLARE @LoadTypeID INT
	DECLARE @SourceSchemaName VARCHAR(MAX)
	DECLARE @LoadTypeCode VARCHAR(MAX)
	DECLARE @TargetDataEntityID INT
	DECLARE @TargetDataEntityName VARCHAR(MAX)
	DECLARE @TargetDatabaseName VARCHAR(MAX)
	DECLARE @TargetSchemaName VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	DECLARE @HashKeyFieldName VARCHAR(MAX)
	DECLARE @TargetDatabaseID INT
	DECLARE @CreateDT_Last_FieldName VARCHAR(MAX)
	DECLARE @DataEntityType VARCHAR(MAX)
	DECLARE @TargetDatabaseEnvironmentTypeID INT
	--DECLARE @StageTalbe_LastCreate 
	
	SET @LoadTypeID = (SELECT LoadTypeID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @SourceSchemaName = (SELECT Source_SchemaName FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))
	SET @TargetDatabaseName = (SELECT Target_DB FROM [DMOD].[vw_LoadConfig] WHERE LoadConfigID = @LoadConfigID)
	SET @TargetSchemaName = (SELECT Target_SchemaName FROM [DMOD].[vw_LoadConfig] WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDatabaseID = (SELECT Target_DatabaseID FROM [DMOD].[vw_LoadConfig] WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
	SET @TargetDatabaseEnvironmentTypeID = (SELECT DatabaseEnvironmentTypeID FROM DC.[Database] WHERE DatabaseID = @TargetDatabaseID)
	SET @DataEntityType = (SELECT DataEntityTypeCode FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
	
	-- Get CreateDT Field 
	SET @CreateDT_Last_FieldName = (SELECT PARSENAME(DMOD.udf_get_SatelliteCreatedDT_Last_Field(@LoadConfigID), 1))

	-- For the TargetDataEntity Ensamble what is the that is being loaded?
	-- :DEBUG:
	--SELECT @CreateDT_Last_FieldName, @TargetDataEntityName, @TargetSchemaName, @DataEntityType, @SourceSchemaName
	-- :DEBUG:
	
	-- TODO: REFS
	DECLARE @DataVault_Schema VARCHAR(MAX) = 'raw'
	DECLARE @DataVaultDatabasePurposeID INT = (SELECT DatabasePurposeID FROM DC.[DatabasePurpose] WHERE DatabasePurposeCode = 'DataVault')
	DECLARE @DataVaultDatabaseID INT = (SELECT DatabaseID FROM DC.[Database] WHERE DatabasePurposeID = @DataVaultDatabasePurposeID AND DatabaseEnvironmentTypeID = @TargetDatabaseEnvironmentTypeID)
	DECLARE @DataVaultDatabaseName VARCHAR(MAX) = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @DataVaultDatabaseID)
	DECLARE @EntityName VARCHAR(MAX) = REPLACE(REPLACE(@TargetDataEntityName, @SourceSchemaName + '_',''), '_' + @TargetSchemaName + '_' + @DataEntityType,'')
	

	-- For KEYS first for HVD then MVD THEN LVD then KEYS
	-- OTherwise just take whichever velocity passed
	DECLARE @Entity_SAT_Name VARCHAR(MAX)
	DECLARE @Entity_HUB_Name VARCHAR(MAX)
	DECLARE @Entity_Return_Name VARCHAR(MAX)

	SET @Entity_HUB_Name = 'HUB_' + @EntityName

	IF(@DataEntityType = 'HVD' OR @DataEntityType = 'MVD'  OR @DataEntityType = 'LVD')
	BEGIN
		SET @Entity_SAT_Name = 'SAT_' + @EntityName + '_' + @TargetSchemaName + '_' + @DataEntityType

		-- :DEBUG:
		--SELECT @Entity_SAT_Name, @Entity_HUB_Name, @DataVault_Schema, @DataVaultDatabasePurposeID, @DataVaultDatabaseID
		-- :DEBUG:

		-- Get the DataEntityID for the SAT  (Try this first)
		SET @Entity_Return_Name = (
										SELECT 
											de.DataEntityName
										FROM 
											[DC].[Field] AS f
										INNER JOIN
											[DC].[DataEntity] AS de
											ON de.DataEntityID = f.DataEntityID
										INNER JOIN 
											[DC].[Schema] AS s
											ON s.SchemaID = de.SchemaID
										INNER JOIN 
											[DC].[Database] AS db
											ON db.DatabaseID = s.DatabaseID
										INNER JOIN 
											[DC].[DatabasePurpose] AS dp
											ON dp.DatabasePurposeID = db.DatabasePurposeID
										WHERE
											f.FieldName = @CreateDT_Last_FieldName
										AND
											de.DataEntityName = @Entity_SAT_Name
										AND
											s.SchemaName = @DataVault_Schema
										AND
											dp.DatabasePurposeID = @DataVaultDatabasePurposeID
										AND
											db.DatabaseID = @DataVaultDatabaseID
									)

		-- Get the DataEntityID for the SAT 
		IF(@Entity_Return_Name IS NULL)
		BEGIN
			SET @Entity_Return_Name = (
											SELECT 
												de.DataEntityName
											FROM 
												[DC].[Field] AS f
											INNER JOIN
												[DC].[DataEntity] AS de
												ON de.DataEntityID = f.DataEntityID
											INNER JOIN 
												[DC].[Schema] AS s
												ON s.SchemaID = de.SchemaID
											INNER JOIN 
												[DC].[Database] AS db
												ON db.DatabaseID = s.DatabaseID
											INNER JOIN 
												[DC].[DatabasePurpose] AS dp
												ON dp.DatabasePurposeID = db.DatabasePurposeID
											WHERE
												f.FieldName = @CreateDT_Last_FieldName
											AND
												de.DataEntityName = @Entity_HUB_Name
											AND
												s.SchemaName = @DataVault_Schema
											AND
												dp.DatabasePurposeID = @DataVaultDatabasePurposeID
											AND
												db.DatabaseID = @DataVaultDatabaseID
										)
		END

		IF(@Entity_Return_Name IS NULL)
		BEGIN
			SET @Entity_Return_Name = 'UNKNOWN ENTITY, FIX THIS!'
		END
	END

	ELSE

	BEGIN
		SET @Entity_SAT_Name = 'SAT_' + @EntityName + '_' + @TargetSchemaName + '_' + 'HVD'

		-- Get the DataEntityID for the SAT (TEST HVD FIRST)
		SET @Entity_Return_Name = (
										SELECT 
											de.DataEntityName
										FROM 
											[DC].[Field] AS f
										INNER JOIN
											[DC].[DataEntity] AS de
											ON de.DataEntityID = f.DataEntityID
										INNER JOIN 
											[DC].[Schema] AS s
											ON s.SchemaID = de.SchemaID
										INNER JOIN 
											[DC].[Database] AS db
											ON db.DatabaseID = s.DatabaseID
										INNER JOIN 
											[DC].[DatabasePurpose] AS dp
											ON dp.DatabasePurposeID = db.DatabasePurposeID
										WHERE
											f.FieldName = @CreateDT_Last_FieldName
										AND
											de.DataEntityName = @Entity_SAT_Name
										AND
											s.SchemaName = @DataVault_Schema
										AND
											dp.DatabasePurposeID = @DataVaultDatabasePurposeID
										AND
											db.DatabaseID = @DataVaultDatabaseID
									)

		-- IF NO HVD THEN TEST MVD
		IF (@Entity_Return_Name IS NULL)
		BEGIN
			SET @Entity_SAT_Name = 'SAT_' + @EntityName + '_' + @TargetSchemaName + '_' + 'MVD'
			SET @Entity_Return_Name = (
											SELECT 
												de.DataEntityName
											FROM 
												[DC].[Field] AS f
											INNER JOIN
												[DC].[DataEntity] AS de
												ON de.DataEntityID = f.DataEntityID
											INNER JOIN 
												[DC].[Schema] AS s
												ON s.SchemaID = de.SchemaID
											INNER JOIN 
												[DC].[Database] AS db
												ON db.DatabaseID = s.DatabaseID
											INNER JOIN 
												[DC].[DatabasePurpose] AS dp
												ON dp.DatabasePurposeID = db.DatabasePurposeID
											WHERE
												f.FieldName = @CreateDT_Last_FieldName
											AND
												de.DataEntityName = @Entity_SAT_Name
											AND
												s.SchemaName = @DataVault_Schema
											AND
												dp.DatabasePurposeID = @DataVaultDatabasePurposeID
											AND
												db.DatabaseID = @DataVaultDatabaseID
										)
			END

		-- IF NO MVD THEN TEST LVD
		IF (@Entity_Return_Name IS NULL)
		BEGIN
			SET @Entity_SAT_Name = 'SAT_' + @EntityName + '_' + @TargetSchemaName + '_' + 'LVD'
			SET @Entity_Return_Name = (
											SELECT 
												de.DataEntityName
											FROM 
												[DC].[Field] AS f
											INNER JOIN
												[DC].[DataEntity] AS de
												ON de.DataEntityID = f.DataEntityID
											INNER JOIN 
												[DC].[Schema] AS s
												ON s.SchemaID = de.SchemaID
											INNER JOIN 
												[DC].[Database] AS db
												ON db.DatabaseID = s.DatabaseID
											INNER JOIN 
												[DC].[DatabasePurpose] AS dp
												ON dp.DatabasePurposeID = db.DatabasePurposeID
											WHERE
											f.FieldName = @CreateDT_Last_FieldName
										AND
												de.DataEntityName = @Entity_SAT_Name
											AND
												s.SchemaName = @DataVault_Schema
											AND
												dp.DatabasePurposeID = @DataVaultDatabasePurposeID
											AND
												db.DatabaseID = @DataVaultDatabaseID
										)
			END

		-- if none of sats work, try hub
		IF (@Entity_Return_Name IS NULL)
		BEGIN
			SET @Entity_Return_Name = (
											SELECT 
												de.DataEntityName
											FROM 
												[DC].[Field] AS f
											INNER JOIN
												[DC].[DataEntity] AS de
											ON de.DataEntityID = f.DataEntityID
											INNER JOIN 
												[DC].[Schema] AS s
												ON s.SchemaID = de.SchemaID
											INNER JOIN 
												[DC].[Database] AS db
												ON db.DatabaseID = s.DatabaseID
											INNER JOIN 
												[DC].[DatabasePurpose] AS dp
												ON dp.DatabasePurposeID = db.DatabasePurposeID
											WHERE
												f.FieldName = @CreateDT_Last_FieldName
											AND
												de.DataEntityName = @Entity_HUB_Name
											AND
												s.SchemaName = @DataVault_Schema
											AND
												dp.DatabasePurposeID = @DataVaultDatabasePurposeID
											AND
												db.DatabaseID = @DataVaultDatabaseID
										)
			
			END

			IF(@Entity_Return_Name IS NULL)
			BEGIN
				SET @Entity_Return_Name = 'UNKNOWN ENTITY, FIX THIS!'
			END
		END

	-- Now get the Fully Qualiefied Name fot the DE AND Return
	SET @ReturnName = REPLICATE(CHAR(9), 3) + '--!~ Last CreateDT replacement for Incremental Loads' + CHAR(13)
	SELECT @ReturnName = @ReturnName + REPLICATE(CHAR(9), 4) + 'SELECT	@LastCreateDT = ISNULL(MAX(' + QUOTENAME(@CreateDT_Last_FieldName) + '),''1900-01-01'')' + CHAR(13)
	SELECT @ReturnName = @ReturnName + REPLICATE(CHAR(9), 4) + 'FROM ' + QUOTENAME(@DataVaultDatabaseName) + '.' + QUOTENAME(@DataVault_Schema) + '.' + QUOTENAME(@Entity_Return_Name)  + CHAR(13)
	SELECT @ReturnName = @ReturnName + REPLICATE(CHAR(9), 3) + '-- Last CreateDT replacement for Incremental Loads ~!' + CHAR(13)

	-- :DEBUG:
	--		SELECT @ReturnName
	-- :DEBUG:

	RETURN @ReturnName

END

GO
