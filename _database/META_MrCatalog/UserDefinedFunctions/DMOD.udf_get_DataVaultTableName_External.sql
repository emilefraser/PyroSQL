SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

*/
----	Select [DMOD].[udf_get_DataVaultTableName](70)
---- Select [DMOD].[udf_get_DataVaultTableName](54)
--Select [DMOD].[udf_get_DataVaultTableName](62)

CREATE FUNCTION [DMOD].[udf_get_DataVaultTableName_External](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @DataVaultTableName VARCHAR(MAX) = '';
	DECLARE @DataVaultExternalTablePrefix VARCHAR(MAX) = 'ext_DEV_DataVault_raw_' --TODO: Make this more Dynamic
	DECLARE @LoadTypeCode VARCHAR(MAX)
	DECLARE @DataVaultObjectType VARCHAR(MAX)
	
	SET @LoadTypeCode = (SELECT [DMOD].[udf_get_LoadTypeCode](@LoadConfigID))

	SET @DataVaultObjectType = 
	(
		SELECT
			CASE SUBSTRING(@LoadTypeCode, LEN(@LoadTypeCode) - 3, 4)
				WHEN 'KEYS' THEN 'HUB'
				WHEN '_LVD' THEN 'SAT'
				WHEN '_MVD' THEN 'SAT'
				WHEN '_HVD' THEN 'SAT'
				WHEN 'LINK' THEN 'LINK'
							ELSE 'UNK'
			END
	)

	  SET  @DataVaultTableName = 
	 ( 
			SELECT @DataVaultExternalTablePrefix 
					+ @DataVaultObjectType + '_'
					  + REPLACE(DC.udf_GetDataEntityNameForDataEntityID(lc.TargetDataEntityID), DC.udf_GetSchemaNameForDataEntityID(lc.SourceDataEntityID)+ '_', '')
			  FROM [DMOD].[LoadConfig] AS lc
			  WHERE lc.LoadConfigID =  @LoadConfigID
	 )

	RETURN QUOTENAME(@DataVaultTableName);
END;

GO
