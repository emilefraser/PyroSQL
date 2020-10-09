SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DMOD].[vw_rpt_Validate_DatabaseWithNoPurpose] AS
SELECT
	db.DatabaseID
	, db.DatabaseName
	, db.AccessInstructions
	, db.Size
	, db.DatabaseInstanceID
	, dbi.DatabaseInstanceName
	, db.SystemID
	, s.SystemName
	, db.ExternalDatasourceName
	, db.DBDatabaseID
	, db.CreatedDT
	, db.UpdatedDT
	, db.IsActive
	, db.LastSeenDT
FROM
	[DC].[Database] db
		LEFT JOIN DC.DatabaseInstance dbi	ON db.DatabaseInstanceID = dbi.DatabaseInstanceID AND dbi.IsActive = 1
		LEFT JOIN DC.[System] s				ON db.SystemID = s.SystemID AND s.IsActive = 1
WHERE
	db.DatabasePurposeID Is Null
	AND db.IsActive = 1

GO
