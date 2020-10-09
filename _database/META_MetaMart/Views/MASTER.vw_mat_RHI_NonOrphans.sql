SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [MASTER].[vw_mat_RHI_NonOrphans] AS

SELECT DISTINCT
       RHI1.[ReportingHierarchyItemID]
      ,RHI1.[ItemCode]
      ,RHI1.[ItemName]
      ,RHI1.[ReportingHierarchyTypeID]
      ,RHI1.[ParentItemID]
      ,RHI1.[CompanyID]
      ,RHI1.[ReportingHierarchySortOrder]
      ,RHI1.[CreatedDT]
      ,RHI1.[UpdatedDT]
      ,RHI1.[IsActive]
FROM [MASTER].[ReportingHierarchyItem] RHI1
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHI2 
ON RHI2.ParentItemID = RHI1.ReportingHierarchyItemID
LEFT JOIN [MASTER].[ReportingHierarchyItem] RHI3
ON RHI3.ReportingHierarchyItemID = RHI1.ParentItemID 
WHERE RHI2.ParentItemID IS NOT NULL OR RHI3.ReportingHierarchyItemID IS NOT NULL

GO
