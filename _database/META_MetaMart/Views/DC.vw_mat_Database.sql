SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [DC].[vw_mat_Database] AS
SELECT
	db.DatabaseID AS [Database ID],
	db.DatabaseName AS [Database Name],
	db.AccessInstructions AS [Access Instructions],
	db.Size AS [Size],
	db.DatabaseInstanceID AS [Database Instance ID],
	dbi.DatabaseInstanceName AS [Database Instance Name],
	srv.ServerID AS [Server ID],
	srv.ServerName AS [Server Name],
	db.SystemID AS [System ID],
	s.SystemName AS [System Name],
	db.ExternalDatasourceName AS [External Datasource Name],
	db.DatabasePurposeID AS [Database Purpose ID],
	dbp.DatabasePurposeName AS [Database Purpose Name],
	db.DBDatabaseID AS [DB Database ID],
	db.DatabaseEnvironmentTypeID AS [Database Environment Type ID],
	gd.DetailTypeCode AS [Database Environment Type Name],
	db.IsBaseDatabase AS [Is Base Database],
	db.BaseReferenceDatabaseID AS [Base Reference Database ID],
	db2.DatabaseName AS [Base Reference Database Name], 
	db.CreatedDT AS [Created Date],
	db.UpdatedDT AS [Updated Date],
	db.IsActive AS [Is Active],
	db.LastSeenDT AS [Last Seen Date Time]

	FROM [DC].[Database] db
	LEFT JOIN DC.DatabaseInstance as dbi
	ON db.DatabaseInstanceID = dbi.DatabaseInstanceID
	LEFT JOIN DC.DatabasePurpose dbp
	ON db.DatabasePurposeID = dbp.DatabasePurposeID
	LEFT JOIN [DC].[System] s
	ON db.SystemID = s.SystemID
	LEFT JOIN [DC].[Database] db2
	ON db.BaseReferenceDatabaseID = db2.DatabaseID
	LEFT JOIN [TYPE].Generic_Detail gd
	ON db.DatabaseEnvironmentTypeID = gd.DetailID
	LEFT JOIN [DC].[Server] srv
	ON dbi.ServerID = srv.ServerID

GO
