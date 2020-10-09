SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [MASTER].[vw_mat_SortOrderValue] with schemabinding AS 
SELECT SortOrderValueID AS [Sort Order Value ID],
SortOrderGroupingID AS [Sort Order Grouping ID],
SortOrder AS [Sort Order],
DataValue AS [Data Value],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active] 
FROM [MASTER].[SortOrderValue]

GO
