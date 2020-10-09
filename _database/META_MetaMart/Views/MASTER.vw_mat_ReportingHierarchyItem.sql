SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [MASTER].[vw_mat_ReportingHierarchyItem] AS
SELECT 
CompanyID AS [Company ID],
ReportingHierarchyItemID AS [Reporting Hierarchy Item ID],
ReportingHierarchyTypeID AS [Reporting Hierarchy Type ID],
ParentItemID AS [Parent Item ID],
ReportingHierarchySortOrder AS [Reporting Hierarchy Sort Order],
ItemCode AS [Item Code],
ItemName AS [Item Name],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active]
FROM [MASTER].[ReportingHierarchyItem]

GO
