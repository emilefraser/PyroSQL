SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE VIEW [MASTER].[vw_mat_ReportingHierarchyType] AS
SELECT 
RH.ReportingHierarchyTypeID AS [Reporting Hierarchy Type ID],
RH.DataDomainID AS [Data Domain ID],
ReportingHierarchyTypeCode AS [Reporting Hierarchy Type Code],
ReportingHierarchyTypeName AS [Reporting Hierarchy Type Name],
ReportingHierarchyDescription AS [Reporting Hierarchy Description],
HierarchyLevelsLimit AS [Hierarchy Levels Limit],
IsUniqueBKMapping AS [Is Unique BK Mapping],
IsMultipleTopParentAllowed AS [Is Multiple Top Parent Allowed],
RH.CreatedDT AS [Created Date],
RH.UpdatedDT AS [Updated Date],
RH.IsActive AS [Is Active]
FROM [MASTER].[ReportingHierarchyType] RH
LEFT JOIN 
[GOV].[DataDomain] DD
ON 
RH.DataDomainID = DD.DataDomainID

GO
