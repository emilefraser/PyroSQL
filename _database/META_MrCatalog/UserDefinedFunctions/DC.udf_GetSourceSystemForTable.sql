SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- Description: Returns the System abbreviation for a table
-- =============================================
CREATE FUNCTION [DC].[udf_GetSourceSystemForTable]
(
	@DataEntityID INT
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @System VARCHAR(10)

	SELECT @System = [sys].SystemAbbreviation
	  FROM DC.DataEntity de
		   INNER JOIN DC.[Schema] s ON
				s.SchemaID = de.SchemaID
		   INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
		   INNER JOIN DC.[System] [sys] ON
				[sys].SystemID = db.SystemID
				
    RETURN @System
END

GO
