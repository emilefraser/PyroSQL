SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [dbo].[vw_mat_Database] AS
SELECT
	DatabaseID AS [Database ID],
	DatabaseName AS [Database Name],
	AccessInstructions AS [Access Instructions],
	Size AS [Size],
	DatabaseInstanceID AS [Database Instance ID],
	SystemID AS [System ID],
	ExternalDatasourceName AS [External Datasource Name],
	DatabasePurposeID AS [Database Purpose ID],
	DBDatabaseID AS [DB Database ID],
	CreatedDT AS [Created Date],
	UpdatedDT AS [Updated Date],
	IsActive AS [Is Active],
	LastSeenDT AS [Last Seen Date Time]

	FROM [DC].[Database]

GO
