SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019


--	SELECT * FROM DMOD.vw_LoadConfig WHERE Target_DEName LIKE '%REF%'

--	Sample Execution Statement
--	Select [DMOD].[udf_get_DataVaultBusinessHashKeyName](651)
--	select [dmod].[udf_get_DataVaultBusinessHashKeyName] (3807)

	SELECT TOP 5 * FROM DC.DataEntity WHERE DataEntityName LIKE 'LINK_%' AND DataEntityName LIKE '%Container%' 
	SELECT TOP 5 * FROM DC.DataEntity WHERE DataEntityName LIKE 'SAT_%'
*/

CREATE FUNCTION [DMOD].[udf_get_DataVaultBusinessHashKeyName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	
	--DECLARE @LoadConfigID INT = 806

	DECLARE @ReturnName VARCHAR(MAX)
	
	DECLARE @LoadTypeID INT
	DECLARE @LoadTypeCode VARCHAR(MAX)
	DECLARE @DataVaultObjectType VARCHAR(MAX)
	DECLARE @SourceDataEntityID INT
	DECLARE @TargetDataEntityID INT
	DECLARE @SourceDataEntityName VARCHAR(MAX)
	DECLARE @TargetDataEntityName VARCHAR(MAX)
	DECLARE @SourceDatabaseID INT
	DECLARE @TargetDatabaseID INT
	DECLARE @SourceDatabasePurpose VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	DECLARE @SourceSchemaName VARCHAR(MAX)
	DECLARE @TargetSchemaName VARCHAR(MAX)
	
	SET @LoadTypeID = (SELECT LoadTypeID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @LoadTypeCode = (SELECT [DMOD].[udf_get_LoadTypeCode](@LoadConfigID))
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@SourceDataEntityID))
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))
	
	DECLARE @TargetDataEntityTypeCode VARCHAR(MAX) = (SELECT DataEntityTypeCode FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
	DECLARE @TargetDataEntityNamingSuffix VARCHAR(MAX) = (SELECT DataEntityNamingSuffix FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)

	SET @SourceSchemaName = (SELECT [DC].[udf_GetSchemaNameForDataEntityID](@SourceDataEntityID))
	--SELECT @SourceSchemaName

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))


	IF(@TargetDatabasePurpose = 'DataVault')
	BEGIN
		IF(@TargetDataEntityTypeCode = 'HUB')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(@TargetDataEntityName, 'HUB_', 'HK_')
			)
		END
		IF(@TargetDataEntityTypeCode = 'LINK')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(@TargetDataEntityName, 'LINK_', 'HK_')
			)
		END
		IF(@TargetDataEntityTypeCode = 'SATLVD' OR @TargetDataEntityTypeCode = 'SATMVD' OR  @TargetDataEntityTypeCode = 'SATHVD')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(REPLACE(REPLACE(@TargetDataEntityName, 'SAT_', 'HK_'), '_' + @SourceSchemaName, ''), @TargetDataEntityNamingSuffix,'')
			)
		END
		IF(@TargetDataEntityTypeCode = 'REF')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(@TargetDataEntityName, 'REF_', 'HK_')
			)
		END
		IF(@TargetDataEntityTypeCode = 'REFSAT')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(REPLACE(REPLACE(@TargetDataEntityName, 'REFSAT_', 'HK_'), '_' + @SourceSchemaName, ''), '_LVD','')
			
			)
		END
	END

	--SELECT QUOTENAME(@ReturnName) 

	
	RETURN QUOTENAME(@ReturnName)

END

GO
