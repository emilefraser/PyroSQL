SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 OCt 2018
-- Description: Returns the Database ID of the Stage database
-- =============================================
CREATE FUNCTION [DC].[udf_GetStageDatabaseID]
(
)
RETURNS INT
AS
BEGIN

	DECLARE @DatabaseID INT

	SELECT @DatabaseID = db.DatabaseID
	  FROM DC.[Database] db
		   INNER JOIN DC.DatabasePurpose dbpurp ON
				dbpurp.DatabasePurposeID = db.DatabasePurposeID
	 WHERE dbpurp.DatabasePurposeName = 'Stage'
	
    RETURN @DatabaseID
END

GO
