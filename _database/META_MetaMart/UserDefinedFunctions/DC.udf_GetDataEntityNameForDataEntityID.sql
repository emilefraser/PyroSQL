SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Ansa Bosch
-- Create Date: 10 January 2019
-- Description: Returns the Data Entity Name for a Data Entity
-- =============================================
CREATE FUNCTION [DC].[udf_GetDataEntityNameForDataEntityID]
(
	@DataEntityID INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @DataEntityName VARCHAR(100)

	SELECT @DataEntityName = DataEntityName
	FROM DC.[DataEntity] 
	WHERE DataEntityID = @DataEntityID
	RETURN @DataEntityName

END

GO
