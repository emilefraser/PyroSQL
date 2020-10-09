SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_ODSDataEntityName](60) --[ext_DEV_ODS_D365_DV_CustInvoiceTrans]

*/

CREATE FUNCTION [DMOD].[udf_get_ODSDataEntityName](
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
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@SourceDatabaseID))

	DECLARE @DataEntityID INT

	IF(@SourceDatabasePurpose = 'ODS')
	BEGIN
		SET @DataEntityName = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@SourceDataEntityID)
		)
	END

	ELSE IF(@TargetDatabasePurpose = 'ODS')
	BEGIN
		SET @DataEntityName = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@TargetDataEntityID)
		)
	END

	IF @DataEntityName IS NULL 
	BEGIN
		SET @DataEntityID = (SELECT DC.udf_get_SourceSystem_DataEntityID(@SourceDataEntityID))
		SET @DataEntityName = 
		(
			
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@DataEntityID)
		)
	END

	IF @DataEntityName IS NULL 
	BEGIN
		SET @DataEntityID = (SELECT DC.udf_get_SourceSystem_DataEntityID(@TargetDataEntityID))
		SET @DataEntityName = 
		(
			SELECT DC.udf_GetDataEntityNameForDataEntityID(@DataEntityID)
		)
	END

	IF @DataEntityName IS NULL
		SET @DataEntityID = 'FIX THIS'
		
	RETURN QUOTENAME(@DataEntityName)

END;

GO
