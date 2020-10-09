SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
	Author:      Emile Fraser
	Create Date: 6 June 2019

	Sample Execution Statement
	Description: Gets StageAreaTableNameHisy for a given ConfigID
	SELECT [DMOD].[udf_get_StageAreaHistoryTableName](70)
*/

CREATE FUNCTION [DMOD].[udf_get_StageAreaHistoryTableName](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @StageAreaTableNameHist VARCHAR(MAX) = '';
	  
	 SET  @StageAreaTableNameHist = 
	 ( 
		SELECT 
			QUOTENAME(DC.udf_GetDataEntityNameForDataEntityID(TargetDataEntityID) + '_Hist')
		FROM 
			[DMOD].[LoadConfig] AS lc
		WHERE 
			lc.LoadConfigID = @LoadConfigID
	)


	RETURN @StageAreaTableNameHist;
END;


GO
