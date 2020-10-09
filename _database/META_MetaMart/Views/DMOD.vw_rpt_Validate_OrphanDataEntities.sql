SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_OrphanDataEntities] AS

SELECT
	  de.SchemaID 
	, de.DataEntityID
	, de.DataEntityName
FROM
	DC.DataEntity de
		LEFT JOIN DC.[Schema] s	ON de.SchemaID = s.SchemaID AND s.IsActive = 1
WHERE
	(de.SchemaID Is Null
	OR s.SchemaID Is Null)
	AND de.IsActive = 1


GO
