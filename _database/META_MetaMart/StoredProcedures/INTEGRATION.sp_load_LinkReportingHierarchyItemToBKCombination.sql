SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author: Wium Swart
-- Create Date: 6 June 2019
-- Description: Stored Proc inserts records into LinkReportingHierarchyItemToBKCombination 
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_LinkReportingHierarchyItemToBKCombination]
AS
INSERT INTO MASTER.LinkReportingHierarchyItemToBKCombination
          (ReportingHierarchyItemID,
		   SortOrder)
SELECT
          RHI.ReportingHierarchyItemID, 
		  null
FROM MASTER.ReportingHierarchyItem RHI
LEFT JOIN MASTER.LinkReportingHierarchyItemToBKCombination LR ON LR.ReportingHierarchyItemID = RHI.ReportingHierarchyItemID
WHERE LR.ReportingHierarchyItemID IS NULL

GO
