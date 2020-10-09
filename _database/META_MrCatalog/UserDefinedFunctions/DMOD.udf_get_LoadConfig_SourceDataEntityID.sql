SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Emile Fraser
-- Create Date: 10 September 2019
-- Description: Gets SourceDataEntityID from LoadConfig
-- =============================================
CREATE FUNCTION [DMOD].[udf_get_LoadConfig_SourceDataEntityID]
(
	@LoadConfigID INT
)
RETURNS INT
AS
BEGIN

	DECLARE @Return_Int INT = 
	(
		SELECT 
			SourceDataEntityID 
		FROM 
			DMOD.LoadConfig
		WHERE
			LoadConfigID = @LoadConfigID
	)

    RETURN @Return_Int
END

GO
