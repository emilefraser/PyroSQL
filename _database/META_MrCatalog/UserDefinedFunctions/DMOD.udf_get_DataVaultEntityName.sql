SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_DataVaultEntityName](651) --[ext_DEV_Stage_D365_DV_CustInvoiceTrans]
*/


CREATE    FUNCTION [DMOD].[udf_get_DataVaultEntityName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

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

	DECLARE @TableNameReturn VARCHAR(MAX)
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@SourceDataEntityID))
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))


	IF(@SourceDatabasePurpose = 'DataVault')
	BEGIN
		SET @TableNameReturn = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@SourceDataEntityID)
		)
	END

	ELSE IF(@TargetDatabasePurpose = 'DataVault')
	BEGIN
		SET @TableNameReturn = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@TargetDataEntityID)
		)
	END
	
    ELSE IF(@TargetDatabasePurpose = 'StageArea')
	BEGIN
		SET @TableNameReturn = 
		(
			SELECT PARSENAME([DMOD].[udf_get_DataVaultTableName](@LoadConfigID), 1)
		)
	END
	

	ELSE 
	BEGIN
		SET @TableNameReturn = 'FIX THIS'
	END

	RETURN QUOTENAME(@TableNameReturn)

END

GO
