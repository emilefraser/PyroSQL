SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 16 Oct 2018
-- =============================================
CREATE FUNCTION [DC].[udf_GetSourceSystemIDForDataEntityID]
(
	@DataEntityID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @System INT = NULL

	SELECT @System = CASE WHEN schema_sys.SystemID IS NOT NULL
						THEN schema_sys.SystemID
						ELSE db_sys.SystemID
						END
	  FROM DC.DataEntity de
		   INNER JOIN DC.[Schema] s ON
				s.SchemaID = de.SchemaID
		   INNER JOIN DC.[Database] db ON
				db.DatabaseID = s.DatabaseID
			left join DC.[System] schema_sys on schema_sys.SystemID = s.SystemID
			left join DC.[System] db_sys on db_sys.SystemID = db.SystemID
	 WHERE de.DataEntityID = @DataEntityID

    RETURN @System
END

GO
