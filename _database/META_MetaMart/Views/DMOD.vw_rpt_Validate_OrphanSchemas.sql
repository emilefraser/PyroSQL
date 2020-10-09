SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_OrphanSchemas] AS

SELECT
	  s.DatabaseID 
	, s.SchemaID 
	, s.SchemaName 
FROM
	DC.[Schema] s
		LEFT JOIN DC.[Database] db	ON s.DatabaseID = db.DatabaseID 
WHERE
	s.DatabaseID Is Null
	OR db.DatabaseID Is Null

GO
