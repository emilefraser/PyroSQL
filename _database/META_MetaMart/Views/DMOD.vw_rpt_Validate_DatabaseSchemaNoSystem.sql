SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DMOD].[vw_rpt_Validate_DatabaseSchemaNoSystem] AS

SELECT
	  db.DatabaseID 
	, db.DatabaseName
	, db.SystemID AS DBSystemID
	, s.SchemaID 
	, s.SchemaName
	, s.SystemID AS SchemaSystemID
FROM
	DC.[Schema] s
		INNER JOIN	DC.[Database] db	ON s.DatabaseID = db.DatabaseID AND db.IsActive = 1
		LEFT JOIN	DC.[System] ss		ON s.SystemID = ss.SystemID AND ss.IsActive = 1
		LEFT JOIN	DC.[System] ds		ON db.SystemID = ds.SystemID  AND ds.IsActive = 1
WHERE
	(s.SystemID  Is Null
	AND db.SystemID Is Null)
	OR (ss.SystemID Is Null
	AND ds.SystemID Is Null)
	AND s.IsActive = 1



GO
