SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE VIEW [DC].[vw_mat_Database] AS
SELECT
db.DatabaseID AS [Database ID],
db.DatabaseName AS [Database Name],
db.AccessInstructions AS [Access Instructions],
db.Size AS [Size],
db.DatabaseInstanceID AS [Database Instance ID],
dbi.DatabaseInstanceName,
db.SystemID AS [System ID],
s.SystemName AS [System Name],
db.ExternalDatasourceName AS [External Datasource Name],
db.DatabasePurposeID AS [Database Purpose ID],
dbp.DatabasePurposeName,
db.DBDatabaseID AS [DB Database ID],
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
ON
db.SystemID = s.SystemID

GO
