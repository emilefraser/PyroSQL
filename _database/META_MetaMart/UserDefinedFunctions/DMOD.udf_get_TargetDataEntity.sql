SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--	Select [DMOD].[udf_get_ODSDataEntityName](5)
*/

CREATE FUNCTION [DMOD].[udf_get_TargetDataEntity](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @DataEntityName VARCHAR(MAX) = '';

	  SELECT @DataEntityName = QUOTENAME(REPLACE(REPLACE(REPLACE(de.DataEntityName, 'dbo_', ''), '_KEYS', ''), '_' + s.[SchemaName],'')) 
			FROM [DMOD].[LoadConfig] AS lc
			  INNER JOIN [DC].[DataEntity] AS de
			  ON de.DataEntityID = lc.TargetDataEntityID
			  INNER JOIN [DC].[Schema] AS s
			  ON de.SchemaID = s.SchemaID
			  WHERE lc.LoadConfigID = @LoadConfigID

	RETURN @DataEntityName;
END;

GO
