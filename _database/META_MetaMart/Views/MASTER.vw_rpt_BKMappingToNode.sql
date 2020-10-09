SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [MASTER].[vw_rpt_BKMappingToNode] AS

-- Get CSV values
SELECT HIGH.ReportingHierarchyItemID, SUBSTRING(
(SELECT ', ' + s.Businesskey
FROM 

(SELECT RHI.ReportingHierarchyItemID, LBK.Businesskey 
 FROM [MASTER].[ReportingHierarchyItem] RHI
 LEFT JOIN [MASTER].[LinkReportingHierarchyItemToBKCombination] RHBK
 ON RHBK.ReportingHierarchyItemID = RHI.ReportingHierarchyItemID
 LEFT JOIN [MASTER].[LinkBKCombination] LBK 
 ON LBK.LinkID = RHBK.LinkID
 WHERE LBK.LinkID is not null) s
 WHERE s.ReportingHierarchyItemID = HIGH.ReportingHierarchyItemID

ORDER BY s.Businesskey
FOR XML PATH('')),2,200000) AS BusinessKeys
FROM [MASTER].[ReportingHierarchyItem] HIGH

GO
