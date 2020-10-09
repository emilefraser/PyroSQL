SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- Emile Fraser
-- Select [DC].[udf_get_DatabaseID_from_DataEntityID](63)
CREATE FUNCTION [DC].[udf_get_DatabaseID_from_DataEntityID]
(
    @DataEntityID int
)
RETURNS INT
AS
BEGIN
	
	DECLARE @DatabaseID int

	SELECT	
		@DatabaseID = db.DatabaseID
	FROM	
		DC.[DataEntity]  AS de
	INNER JOIN 
		DC.[Schema] AS s
		ON s.SchemaID = de.SchemaID
	INNER JOIN 
		DC.[Database] AS db
		ON s.[DatabaseID] = db.[DatabaseID]
	WHERE
		de.DataEntityID = @DataEntityID

	RETURN @DatabaseID

END

GO
