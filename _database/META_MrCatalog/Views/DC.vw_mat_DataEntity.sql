SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [DC].[vw_mat_DataEntity] AS
SELECT 
DataEntityID AS [Data Entity ID],
DataEntityName AS [Data Entity Name],
FriendlyName AS [Friendly Name],
[Description] AS [Description],
DataEntityTypeID AS [Data Entity Type ID],
RowsCount AS [Rows Count],
ColumnsCount AS [Columns Count],
Size AS [Size],
DataQualityScore2 AS [Data Quality Score 2],
DataQualityScore AS [Data Quality Score],
SchemaID AS [Schema ID],
DBObjectID AS  [Database Object ID],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active],
LastSeenDT AS [Last Seen Date Time]
From DC.Dataentity


GO
