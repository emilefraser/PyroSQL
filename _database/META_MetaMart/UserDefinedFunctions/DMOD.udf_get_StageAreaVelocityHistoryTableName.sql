SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
-- Author:      Emile Fraser
-- Create Date: 6 June 2019

-- Sample Execution Statement
--	Select [DMOD].[udf_get_StageAreaVelocityHistoryTableName](70)
*/

CREATE FUNCTION [DMOD].[udf_get_StageAreaVelocityHistoryTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @StageAreaVelocityHistoryTableName VARCHAR(MAX)

	SET  @StageAreaVelocityHistoryTableName = 
	 ( 
		SELECT 
			QUOTENAME(REPLACE(DC.udf_GetDataEntityNameForDataEntityID(TargetDataEntityID), 'KEYS', 'LVD')+'_Hist')
		FROM 
			[DMOD].[LoadConfig] AS lc
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)

	IF(@StageAreaVelocityHistoryTableName IS NULL)
		SET  @StageAreaVelocityHistoryTableName = 
		 ( 
			SELECT 
				QUOTENAME(REPLACE(DC.udf_GetDataEntityNameForDataEntityID(TargetDataEntityID), 'KEYS', 'MVD')+'_Hist')
			FROM 
				[DMOD].[LoadConfig] AS lc
			WHERE 
				lc.LoadConfigID = @LoadConfigID
		)


	IF(@StageAreaVelocityHistoryTableName IS NULL)
	SET  @StageAreaVelocityHistoryTableName = 
	 ( 
		SELECT 
			QUOTENAME(REPLACE(DC.udf_GetDataEntityNameForDataEntityID(TargetDataEntityID), 'KEYS', 'HVD')+'_Hist')
		FROM 
			[DMOD].[LoadConfig] AS lc
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)


	RETURN @StageAreaVelocityHistoryTableName;
END;

GO
