SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_StageDataEntityName](60) --[ext_DEV_Stage_D365_DV_CustInvoiceTrans]

*/

CREATE FUNCTION [DMOD].[udf_get_StageAreaTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @DataEntityName VARCHAR(MAX)
	
	DECLARE @SourceDataEntityID INT
	DECLARE @TargetDataEntityID INT
	DECLARE @SourceDatabaseID INT
	DECLARE @TargetDatabaseID INT
	DECLARE @SourceDatabasePurpose VARCHAR(MAX)
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	
	SET @SourceDataEntityID = (SELECT SourceDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)

	SET @SourceDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@SourceDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	
	SET @SourceDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))

	IF(@SourceDatabasePurpose = 'StageArea')
		SET @DataEntityName = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@SourceDataEntityID)
		)

	ELSE IF(@TargetDatabasePurpose = 'StageArea')
		SET @DataEntityName = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@TargetDataEntityID)
		)

	IF @DataEntityName IS NULL 
			SET @DataEntityName = 'FIX THIS'

	RETURN QUOTENAME(@DataEntityName)

END;

GO
