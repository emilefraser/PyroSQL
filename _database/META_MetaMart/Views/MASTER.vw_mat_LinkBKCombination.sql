SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [MASTER].[vw_mat_LinkBKCombination] AS
SELECT 
lb.LinkBKCombinationID AS [Link BK Combination ID],
lb.DataCatalogFieldID AS [Data Catalog Field ID],
lb.LinkID AS [Link ID],
lb.BusinessKey AS [Business Key],
lb.CreatedDT AS [Created Date],
lb.UpdatedDT AS [Updated Date],
lb.IsActive AS [Is Active],
lrhib.ReportingHierarchyItemID AS [Reporting Hierarchy Item ID],
rhi.ReportingHierarchyTypeID AS [Reporting Hierarchy Type ID]
FROM [MASTER].[LinkBKCombination] lb
LEFT JOIN [MASTER].[LinkReportingHierarchyItemToBKCombination] lrhib
ON lrhib.LinkID = lb.LinkID
LEFT JOIN [MASTER].[ReportingHierarchyItem] rhi
ON rhi.ReportingHierarchyItemID = lrhib.ReportingHierarchyItemID 


GO
