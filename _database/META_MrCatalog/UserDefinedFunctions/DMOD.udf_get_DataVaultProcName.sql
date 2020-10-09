SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
*/

-- Sample Execution Statement
--	Select [DMOD].[udf_get_DataVaultProcName](1285)
-- SELECT DMOD.[udf_get_DataVaultProcName](1312)
/**/
CREATE FUNCTION [DMOD].[udf_get_DataVaultProcName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

	--DECLARE @LoadConfigID INT = 1285
	DECLARE @DataVaultProcName VARCHAR(MAX) = '';

	DECLARE @LoadTypeID INT = (SELECT LoadTypeID FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)
	DECLARE @DataEntityTypeCode VARCHAR(MAX) = (SELECT DataEntityTypeCode FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
	DECLARE @DataEntityTypePrefix VARCHAR(MAX) = (SELECT DataEntityNamingPrefix FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
	DECLARE @DataEntityTypeSuffix VARCHAR(MAX) = (SELECT DataEntityNamingSuffix FROM DMOD.vw_LoadType WHERE LoadTypeID = @LoadTypeID)
	DECLARE @SystemName VARCHAR(MAX)  = (SELECT Source_SchemaName FROM DMOD.vw_LoadConfig WHERE LoadConfigID = @LoadConfigID)

	DECLARE @DataEntityName VARCHAR(MAX) = 
	(
		SELECT 
			de.DataEntityName
		FROM 
				[DMOD].[LoadConfig] AS lc
			INNER JOIN 
				[DMOD].[LoadType] AS lt
				ON lc.LoadTypeID = lt.LoadTypeID
			INNER JOIN 
				[DC].[DataEntity] AS de
				ON de.DataEntityID = lc.TargetDataEntityID
			WHERE
				lc.[LoadConfigID] = @LoadConfigID
	)

	--select @DataEntityName, @DataEntityTypeCode, @DataEntityTypePrefix, @DataEntityTypeSuffix

	--SELECT REPLACE(@DataEntityName, @DataEntityTypeCode + '_','')


	SET  @DataVaultProcName = 
	(
		SELECT 
			QUOTENAME('sp_' + LOWER('load') + LOWER(@DataEntityTypePrefix) + @SystemName + '_' + REPLACE(REPLACE(@DataEntityName, @DataEntityTypePrefix,''), @SystemName + '_', ''))
	)
	
	--SELECT @DataVaultProcName
	
	RETURN @DataVaultProcName;
END;

GO
