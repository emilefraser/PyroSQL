SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_mat_Schema]
AS
(
SELECT
SchemaID AS [Schema ID],
SchemaName AS [Schema Name],
DatabaseID AS [Database ID],
DBSchemaID AS [DB Schema ID],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active],
LastSeenDT AS [Last Seen Date]
FROM dc.[schema]
)

GO
