SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

/*
Author:      Emile Fraser
Create Date: 6 June 2019
Description: Generate a record SourceDataEntityID

--!~ RecSrcDataEntityID
				, 123 AS [RecSrcDataEntityID],
-- End of RecSrcDataEntityID ~!

	DECLARE @LoadConfig INT = 1 --96 --55 -- 96
	SELECT [DMOD].[udf_get_RecSrcDataEntityID] (@LoadConfig)

*/
CREATE FUNCTION [DMOD].[udf_get_RecSrcDataEntityID](
	@LoadConfigID INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @RecSrcDataEntityID INT
	DECLARE @RecSrcDataEntityID_Return VARCHAR(MAX) = ''
	DECLARE @TargetDataEntityID INT


	SET @RecSrcDataEntityID = 
	(
		SELECT 
			lc.SourceDataEntityID
		FROM 
			[DMOD].[LoadConfig] AS lc
		WHERE 
			LoadConfigID = @LoadConfigID
	)

	-- For KEVRO we don't need this part as its alread obtained from the above
	--SET @RecSrcDataEntityID = (SELECT [DC].[udf_get_SourceSystem_DataEntityID](@TargetDataEntityID))

	SELECT @RecSrcDataEntityID_Return = @RecSrcDataEntityID_Return + '--!~ RecSrcDataEntityID' + CHAR(13)
	SELECT @RecSrcDataEntityID_Return = @RecSrcDataEntityID_Return + REPLICATE(CHAR(9),4) + ' , ' + CONVERT(VARCHAR(10), @RecSrcDataEntityID) + ' AS [RecSrcDataEntityID] , '  + CHAR(13)
	SELECT @RecSrcDataEntityID_Return = @RecSrcDataEntityID_Return + '-- End of RecSrcDataEntityID ~!' + CHAR(13)

	RETURN @RecSrcDataEntityID_Return;
END;

GO
