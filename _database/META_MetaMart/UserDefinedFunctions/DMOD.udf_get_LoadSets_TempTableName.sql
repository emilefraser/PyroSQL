SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
*/

-- Sample Execution Statement
--	Select [DMOD].[LoadSets_TempTableName](70)
CREATE FUNCTION [DMOD].[udf_get_LoadSets_TempTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @LoadSets_TempTableName VARCHAR(MAX) = ''

	SELECT  @LoadSets_TempTableName = QUOTENAME(@LoadSets_TempTableName + '#LoadSets' + DC.udf_GetSchemaNameForDataEntityID(lc.TargetDataEntityID) + '_' + de.[DataEntityName])
			  FROM [DMOD].[LoadConfig] AS lc
			  INNER JOIN [DC].[DataEntity] AS de
			  ON de.DataEntityID = lc.TargetDataEntityID
			  WHERE lc.LoadConfigID = @LoadConfigID
			  
	RETURN @LoadSets_TempTableName;
END;

GO
