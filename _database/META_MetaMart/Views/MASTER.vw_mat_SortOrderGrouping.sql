SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [MASTER].[vw_mat_SortOrderGrouping] with schemabinding AS 
SELECT 
SortOrderGroupingID AS [Sort Order Grouping ID],
SortOrderGroupName AS [Sort Order Group Name],
SortOrderGroupCode AS [Sort Order Group Code],
FieldID AS [Field ID],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active],
DataDomainID AS [Data Domain ID] FROM [MASTER].[SortOrderGrouping]

GO
