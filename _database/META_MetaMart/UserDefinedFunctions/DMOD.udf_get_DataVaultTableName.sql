SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_DataVaultTableName](3806) --[ext_DEV_Stage_D365_DV_CustInvoiceTrans]
*/


CREATE FUNCTION [DMOD].[udf_get_DataVaultTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @LoadConfigID INT = 154

	DECLARE @TableNameReturn VARCHAR(MAX)
	
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
	
	SET @LoadTypeCode = (SELECT [DMOD].[udf_get_LoadTypeCode](@LoadConfigID))
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@SourceDataEntityID))
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))
	
	SET @SourceSchemaName = (SELECT [DC].[udf_GetSchemaNameForDataEntityID](@SourceDataEntityID))
	SET @TargetSchemaName = (SELECT [DC].[udf_GetSchemaNameForDataEntityID](@TargetDataEntityID))

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))

	IF(@SourceDatabasePurpose = 'DataVault')
		SET @TableNameReturn = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@SourceDataEntityID)
		)

	ELSE IF(@TargetDatabasePurpose = 'DataVault')
		SET @TableNameReturn = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@TargetDataEntityID)
		)
	
	ELSE IF(@TargetDatabasePurpose = 'StageArea')
	BEGIN
		SET @DataVaultObjectType = 
		(
			SELECT
				CASE SUBSTRING(@LoadTypeCode, LEN(@LoadTypeCode) - 3, 4)
					WHEN 'KEYS' THEN 
									CASE 
										WHEN CHARINDEX('REF_', @TargetDataEntityName) > 0 then 'REF'
										ELSE 'HUB'
									END
					WHEN '_LVD' THEN 
									CASE 
										WHEN CHARINDEX('REF_', @TargetDataEntityName) > 0 then 'REFSAT'
										ELSE 'SAT'
									END
					WHEN '_MVD' THEN 
									CASE 
										WHEN CHARINDEX('REF_', @TargetDataEntityName) > 0 then 'REFSAT'
										ELSE 'SAT'
									END
					WHEN '_HVD' THEN 
									CASE 
										WHEN CHARINDEX('REF_', @TargetDataEntityName) > 0 then 'REFSAT'
										ELSE 'SAT'
									END
					WHEN 'LINK' THEN 'LINK'
								ELSE 'UNK'
				END
		)

		IF(@DataVaultObjectType = 'HUB')
			 SET  @TableNameReturn = 
			 ( 
					SELECT @DataVaultObjectType 
								+ '_'
									+ REPLACE(REPLACE(REPLACE(@TargetDataEntityName, @TargetSchemaName + '_', ''),@SourceSchemaName+'_',''),'_KEYS','')
				  
			 )
		ELSE IF(@DataVaultObjectType = 'SAT')
		SET  @TableNameReturn = 
			 ( 
					SELECT @DataVaultObjectType 
								+ '_'
									+ REPLACE(@TargetDataEntityName, @SourceSchemaName + '_', '')
				)
		ELSE IF(@DataVaultObjectType = 'REF')
		SET  @TableNameReturn = 
			 ( 
					SELECT REPLACE(REPLACE(REPLACE(@TargetDataEntityName, @SourceSchemaName + '_', ''), '_KEYS', ''), '_' + @TargetSchemaName, '')
				)
		ELSE IF(@DataVaultObjectType = 'REFSAT')
		SET  @TableNameReturn = 
			 ( 
					SELECT @DataVaultObjectType 
								+ '_'
									+ REPLACE(REPLACE(@TargetDataEntityName, @SourceSchemaName + '_', ''), 'REF_', '')
				)






	END

	
	
	IF @TableNameReturn IS NULL 
			SET @TableNameReturn = 'FIX THIS'

	RETURN QUOTENAME(@TableNameReturn)

END

GO
