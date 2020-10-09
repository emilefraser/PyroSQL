SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019
*/

-- Sample Execution Statement
--	Select [DMOD].[udf_get_StageAreaProcName](54)

CREATE FUNCTION [DMOD].[udf_get_StageAreaProcName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @StageProcName VARCHAR(MAX) = '';

	SET  @StageProcName = 
	(
		SELECT 
			QUOTENAME(@StageProcName + 'sp_' + [DMOD].[udf_get_LoadTypeCode](@LoadConfigID) + '_' + DC.udf_GetSchemaNameForDataEntityID(lc.TargetDataEntityID) + '_' + de.DataEntityName )
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
	
	RETURN @StageProcName;
END;

GO
