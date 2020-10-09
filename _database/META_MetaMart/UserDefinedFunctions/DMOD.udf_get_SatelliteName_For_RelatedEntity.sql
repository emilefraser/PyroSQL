SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/*
-- Author:      Emile Fraser
-- Create Date: 8 September 2019

-- Sample Execution Statement

select * FROM dmod.vw_Loadconfig where loadconfigid = 26

*/
CREATE FUNCTION [DMOD].[udf_get_SatelliteName_For_RelatedEntity](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @LoadConfigID INT = 86 --26
	DECLARE @LoadTypeID INT
	DECLARE @LoadEntity VARCHAR(10) 
	DECLARE @TableNameReturn VARCHAR(MAX)
	DECLARE @LoadTypeCode VARCHAR(MAX)
	DECLARE @DataVaultObjectType VARCHAR(MAX)
	DECLARE @SourceDataEntityID INT
	DECLARE @TargetDataEntityID INT
	DECLARE @SourceDataEntityName VARCHAR(MAX)
	DECLARE @TargetDataEntityName VARCHAR(MAX)
	DECLARE @SourceDatabaseID INT
	DECLARE @TargetDatabaseID INT
	DECLARE @SourceDatabaseName VARCHAR(MAX)
	DECLARE @TargetDatabaseName VARCHAR(MAX)
	DECLARE @SourceDatabasePurpose VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	DECLARE @SourceSchemaName VARCHAR(MAX)
	DECLARE @TargetSchemaName VARCHAR(MAX)
	
	SET @LoadTypeCode = (SELECT [DMOD].[udf_get_LoadTypeCode](@LoadConfigID))
	SET @LoadTypeID = (SELECT LoadTypeID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @LoadEntity = (SELECT DataEntityTypeCode FROM DMOD.LoadType AS lt INNER JOIN DC.DataEntityType AS dt ON dt.DataEntityTypeID = lt.DataEntityTypeID WHERE LoadTypeID = @LoadTypeID)
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@SourceDataEntityID))
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))
	
	SET @SourceSchemaName = (SELECT [DC].[udf_GetSchemaNameForDataEntityID](@SourceDataEntityID))
	SET @TargetSchemaName = (SELECT [DC].[udf_GetSchemaNameForDataEntityID](@TargetDataEntityID))

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))

	SET @SourceDatabaseName = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @SourceDatabaseID)
	SET @TargetDatabaseName = (SELECT DatabaseName FROM DC.[Database] WHERE DatabaseID = @TargetDatabaseName)
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
	
	--SELECT @TargetDatabasePurpose, @LoadEntity

	-- If we are loading State
	IF (@LoadEntity = 'KEYS')
	BEGIN
		-- If its a KEYS load, need to determine Satellite with highest velocity
		SET @TableNameReturn = REPLACE(REPLACE(@TargetDataEntityName, @SourceSchemaName + '_', 'SAT_'), '_KEYS', '_')

		-- CHECK IF HVD exists
		IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'HVD' and IsActive = 1)
		BEGIN 
			SET @TableNameReturn = @TableNameReturn + 'HVD'
		END

		ELSE IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'MVD' and IsActive = 1)
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'MVD'
		END 

		ELSE IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'LVD' and IsActive = 1)
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'LVD'
		END
			
		ELSE
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'LVD'
		END
	END -- KEYS
	
	ELSE IF (@LoadEntity = 'LVD'  OR @LoadEntity = 'MVD'  OR @LoadEntity = 'HVD')
	BEGIN 
		
		-- Only swap out the schema prefix as per stage with SAT_ prefx
		SET @TableNameReturn = REPLACE(@TargetDataEntityName, @SourceSchemaName + '_', 'SAT_')
	
	END -- VELOCITY

	ELSE IF (@LoadEntity = 'HUB')
	BEGIN
		-- If its a KEYS load, need to determine Satellite with highest velocity
		SET @TableNameReturn = REPLACE(REPLACE(@SourceDataEntityName, @SourceSchemaName + '_', 'SAT_'), '_KEYS', '_')

		-- CHECK IF HVD exists
		IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'HVD' and IsActive = 1)
		BEGIN 
			SET @TableNameReturn = @TableNameReturn + 'HVD'
		END

		ELSE IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'MVD' and IsActive = 1)
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'MVD'
		END 

		ELSE IF EXISTS (SELECT 1 FROM DMOD.Satellite WHERE SatelliteName = @TableNameReturn + 'LVD' and IsActive = 1)
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'LVD'
		END
			
		ELSE
		BEGIN
			SET @TableNameReturn = @TableNameReturn + 'LVD'
		END
	END

	ELSE IF (@LoadEntity = 'SATLVD'  OR @LoadEntity = 'SATMVD'  OR @LoadEntity = 'SATHVD')
	BEGIN 
		-- Only swap out the schema prefix as per stage with SAT_ prefx
		SET @TableNameReturn = @TargetSchemaName
	END -- VELOCITY

	ELSE
	BEGIN

		SET @TableNameReturn = 'Unable To Determine LoadEntity'

	END 


	--SELECT QUOTENAME(@TableNameReturn)
	--RETURN QUOTENAME('DataVault') + '.' + QUOTENAME('raw') + '.' + QUOTENAME(@TableNameReturn)
	RETURN QUOTENAME(@TableNameReturn)

END




GO
