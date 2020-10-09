SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Emile Fraser
-- Create Date: 10 January 2019
-- Description: Returns ghost record
-- SELECT [DMOD].[udf_get_HashKey_GhostField]()
-- =============================================
CREATE FUNCTION [DMOD].[udf_get_HashKey_GhostField]()

RETURNS VARCHAR(40)
AS
BEGIN
    DECLARE @HashRecord_HashKey VARCHAR(100) =
	(
		SELECT CONVERT(VARCHAR(40),
						 HASHBYTES('SHA1',
							  CONVERT(VARCHAR(MAX),'NA')
									)
						, 2)
	)

	RETURN @HashRecord_HashKey

END

GO
