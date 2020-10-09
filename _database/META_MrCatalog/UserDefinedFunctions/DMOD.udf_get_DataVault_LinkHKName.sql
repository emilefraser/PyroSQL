SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--Select [DMOD].[udf_get_DataVault_LinkHKName](1143) 
*/
CREATE   FUNCTION [DMOD].[udf_get_DataVault_LinkHKName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	
	-- :DEBUG:
	--		DECLARE @LoadConfigID INT = 1143
	-- :DEBUG:

	DECLARE @ReturnName VARCHAR(MAX)
	DECLARE @LoadTypeID INT
	DECLARE @LoadTypeCode VARCHAR(MAX)
	DECLARE @DataVaultObjectType VARCHAR(MAX)
	DECLARE @TargetDataEntityID INT
	DECLARE @TargetDataEntityName VARCHAR(MAX)
	DECLARE @TargetDatabaseID INT
	DECLARE @TargetDatabasePurpose VARCHAR(MAX)
	DECLARE @HashKeyFieldName VARCHAR(MAX)
	
	SET @LoadTypeID = (SELECT LoadTypeID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityID = (SELECT TargetDataEntityID FROM DMOD.LoadConfig WHERE LoadConfigID = @LoadConfigID)
	SET @TargetDataEntityName = (SELECT [DC].[udf_GetDataEntityNameForDataEntityID](@TargetDataEntityID))
	SET @TargetDatabaseID = (SELECT [DC].[udf_get_DatabaseID_from_DataEntityID](@TargetDataEntityID))
	SET @TargetDatabasePurpose = (SELECT DC.udf_get_DatabasePurposeCode(@TargetDatabaseID))
	SET @DataVaultObjectType = (SELECT DataEntityTypeCode FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)

	-- :DEBUG:
	--		SELECT @TargetDataEntityID, @TargetDataEntityName, @TargetDatabaseID, @TargetDatabasePurpose, @DataVaultObjectType
	-- :DEBUG:


	IF(@TargetDatabasePurpose = 'DataVault')
	BEGIN
		IF(@DataVaultObjectType = 'LINK')
		BEGIN
			SET @ReturnName = 
			(
				SELECT REPLACE(PARSENAME(@TargetDataEntityName,1), 'LINK_', 'LINKHK_')
			)
		END
	END
	
	ELSE 
	BEGIN
		SET @ReturnName = 'NOT LINKHK!!'
	END

	-- :DEBUG:
	--		SELECT @ReturnName
	-- :DEBUG:

	RETURN QUOTENAME(@ReturnName)

END

GO
