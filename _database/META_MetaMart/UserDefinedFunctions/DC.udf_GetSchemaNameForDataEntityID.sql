SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


-- =============================================
-- Author:      Ansa Bosch
-- Create Date: 10 January 2019
-- Description: Returns the Data Entity Name for a Data Entity
-- =============================================
/*

	SELECT [DC].[udf_GetSchemaNameForDataEntityID](58425)
*/
CREATE FUNCTION [DC].[udf_GetSchemaNameForDataEntityID]
(
	@DataEntityID INT
)
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @SchemaName VARCHAR(100)

	SELECT	@SchemaName = s.SchemaName  
		FROM	dc.[DataEntity] de
			join dc.[Schema] s
				on s.[SchemaId] = de.[SchemaId]
			join dc.[Database] db
				on db.[DatabaseId] = s.[DatabaseId]
		WHERE de.[DataentityId] =  @DataEntityID
	RETURN @SchemaName
END

GO
