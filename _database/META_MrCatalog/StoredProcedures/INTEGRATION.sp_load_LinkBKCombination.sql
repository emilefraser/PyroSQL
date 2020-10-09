SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_LinkBKCombination]

AS

INSERT INTO MASTER.LinkBKCombination
	  (LinkID,
	   DataCatalogFieldID,
	   BusinessKey,
	   CreatedDT,
	   UpdatedDT,
	   IsActive)
SELECT LR.LinkID,
       9215 as DataCatalogFieldID,  -- is currently hard coded.
	   DE.EmployeeNumber, 
	   GETDATE(), 
	   NULL, 
	   P.IsActive 
FROM MASTER.LinkReportingHierarchyItemToBKCombination LR
LEFT JOIN ACCESS.ReportingHierarchyUserAccess RHUA ON RHUA.ReportingHierarchyItemID = LR.ReportingHierarchyItemID
LEFT JOIN ACCESS.PersonAccessControlList PACL ON PACL.PersonAccessControlListID = RHUA.PersonAccessControlListID
LEFT JOIN GOV.OrgChartPosition OCP ON OCP.OrgChartPositionID = PACL.OrgChartPositionID
LEFT JOIN INTEGRATION.ingress_dimemployeeposition DEP ON DEP.PositionCode = OCP.PositionCode
LEFT JOIN INTEGRATION.ingress_dimemployee DE ON DE.Positioncode = DEP.PositionCode
LEFT JOIN MASTER.LinkBKCombination LBK ON LBK.LinkID = LR.LinkID
LEFT JOIN GOV.Person P ON P.PersonUniqueKey = DE.EmployeeKey
WHERE LBK.LinkID IS NULL AND DE.EmployeeNumber IS NOT NULL
ORDER BY LR.LinkID 

UPDATE MASTER.LinkBKCombination
SET 
 --,[DataCatalogFieldID] = IS HARDCODED
    [BusinessKey]= DE.EmployeeNumber
   ,[UpdatedDT] = GETDATE() 
   ,[IsActive] = P.IsActive
FROM MASTER.LinkBKCombination LBK 
LEFT JOIN MASTER.LinkReportingHierarchyItemToBKCombination LR ON LR.LinkID =LBK.LinkID
LEFT JOIN ACCESS.ReportingHierarchyUserAccess RHUA ON RHUA.ReportingHierarchyItemID = LR.ReportingHierarchyItemID
LEFT JOIN ACCESS.PersonAccessControlList PACL ON PACL.PersonAccessControlListID = RHUA.PersonAccessControlListID
LEFT JOIN GOV.OrgChartPosition OCP ON OCP.OrgChartPositionID = PACL.OrgChartPositionID
LEFT JOIN INTEGRATION.ingress_dimemployeeposition DEP ON DEP.PositionCode = OCP.PositionCode
LEFT JOIN INTEGRATION.ingress_dimemployee DE ON DE.Positioncode = DEP.PositionCode
LEFT JOIN GOV.PERSON P ON P.PersonUniqueKey = DE.EmployeeKey
WHERE 
      LBK.[BusinessKey] != DE.EmployeeNumber
	  OR
	  LBK.[UpdatedDT] != GETDATE()
	  OR
	  LBK.[IsActive] != P.IsActive

GO
