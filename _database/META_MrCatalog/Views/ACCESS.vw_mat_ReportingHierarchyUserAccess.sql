SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [ACCESS].[vw_mat_ReportingHierarchyUserAccess] AS
SELECT 
ReportingHierarchyItemID AS [Reporting Hierarchy Item ID],
ReportingHierarchyUserAccessID AS [Reporting Hierarchy User Access ID],
PersonAccessControlListID AS [Person Access Control List ID],
IsDefaultHierarchyItem AS [Is Default Hierarchy Item],
CreatedDT AS [Created Date],
UpdatedDT AS [Updated Date],
IsActive AS [Is Active]
FROM [ACCESS].[ReportingHierarchyUserAccess]

GO
