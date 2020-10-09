SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [MASTER].[vw_mat_LinkReportingHierarchyItemToBKCombination] AS
SELECT 
LinkID AS [Link ID],
ReportingHierarchyItemID AS [Reporting Hierarchy Item ID]
FROM [MASTER].[LinkReportingHierarchyItemToBKCombination]

GO
