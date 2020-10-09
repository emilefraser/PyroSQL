SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- =============================================
-- Author:      Ansa Bosch
-- Create Date: 10 January 2019
-- Description: Returns the Data Entity Name for a Data Entity
-- =============================================
CREATE FUNCTION [DC].[udf_GetSchemaIDForDataEntityID]
(
	@DataEntityID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @SchemaID INT

	SELECT	@SchemaID = s.SchemaID  
		FROM	dc.[DataEntity] de
			join dc.[Schema] s
				on s.[SchemaId] = de.[SchemaId]
			join dc.[Database] db
				on db.[DatabaseId] = s.[DatabaseId]
		WHERE de.[DataentityId] =  @DataEntityID
	RETURN @SchemaID
END

GO
