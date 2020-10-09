SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
*/

-- Sample Execution Statement
--	Select [DMOD].[udf_get_LoadComparison_TempTableName](70)
CREATE FUNCTION [DMOD].[udf_get_LoadComparison_TempTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @LoadComparison_TempTableName VARCHAR(MAX) = ''

	SELECT  @LoadComparison_TempTableName = QUOTENAME(@LoadComparison_TempTableName + '#LoadComparison_' + DC.udf_GetSchemaNameForDataEntityID(lc.TargetDataEntityID) + '_' + de.[DataEntityName])
			  FROM [DMOD].[LoadConfig] AS lc
			  INNER JOIN [DC].[DataEntity] AS de
			  ON de.DataEntityID = lc.TargetDataEntityID
			  WHERE lc.LoadConfigID = @LoadConfigID
			  
	RETURN @LoadComparison_TempTableName;
END;

GO
