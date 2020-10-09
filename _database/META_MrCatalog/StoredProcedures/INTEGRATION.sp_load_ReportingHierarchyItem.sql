SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author: Wium Swart
-- Create Date: 5 June 2019
-- Description: inserts and updates Master.ReportHierarchyItem directly from Dim_EmployeePosition
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_ReportingHierarchyItem]

AS
--Inserts all the new records added to dim employeePOSITION AND ITS IS ACTIVE RELIES ON gov,PERSONeMPLOYEE
INSERT INTO MASTER.ReportingHierarchyItem 
      ([ItemCode]
      ,[ItemName]
      ,[ReportingHierarchyTypeID]
      ,[ParentItemID]
      ,[CompanyID]
      ,[ReportingHierarchySortOrder]
      ,[CreatedDT]
      ,[UpdatedDT]
      ,[IsActive])
SELECT DEP.PositionCode,
       DEP.PositionDescription,
	   29,
	   NULL,
	   C.CompanyID,
	   NULL,
	   GETDATE(),
	   NULL,
	   1 as IsActive
from INTEGRATION.ingress_dimemployeeposition DEP
LEFT JOIN CONFIG.Company C ON C.Companycode = DEP.Companycode
LEFT JOIN (SELECT ItemCode FROM MASTER.ReportingHierarchyItem) RHI ON RHI.ItemCode = DEP.PositionCode
WHERE RHI.ItemCode IS NULL



--Updates reportinghierarchyitmes position description and companyid
UPDATE MASTER.ReportingHierarchyItem 
SET 
      [ItemName] = DEP.PositionDescription,
      --[ReportingHierarchyTypeID] =    --Not accounted for due to it being hard coded
      [CompanyID] = C.CompanyID,
      --[ReportingHierarchySortOrder] = --not accounted for yet
      [UpdatedDT] = GETDATE()
FROM MASTER.ReportingHierarchyItem RHI
LEFT JOIN INTEGRATION.ingress_dimemployeeposition DEP ON DEP.PositionCode = RHI.ItemCode
LEFT JOIN CONFIG.company C ON C.CompanyCode = DEP.CompanyCode
WHERE 
      RHI.ItemName != DEP.PositionDescription
	  OR
      RHI.CompanyID != C.CompanyID



--Sets who the ReportingHierarchyItem reports to
UPDATE MASTER.ReportingHierarchyItem  
SET ParentItemID = i.Parent
FROM (SELECT RHIC.ReportingHierarchyItemID as Child, RHIP.ReportingHierarchyItemID as Parent
FROM MASTER.ReportingHierarchyItem RHIC
LEFT JOIN INTEGRATION.ingress_dimemployeeposition DEPC 
ON DEPC.PositionCode = RHIC.Itemcode
LEFT JOIN INTEGRATION.ingress_dimemployeeposition DEPP 
ON DEPC.ParentEmployeePositionKey = DEPP.EmployeePositionKey
LEFT JOIN MASTER.ReportingHierarchyItem RHIP
ON RHIP.ItemCode = DEPP.PositionCode
) AS i
WHERE ReportingHierarchyItemID = i.Child


--IsActive is set here
--Records that appear in the RHI but not in dim_employee must be set to 0 from 1

UPDATE MASTER.ReportingHierarchyItem  
SET IsActive = 1

UPDATE MASTER.ReportingHierarchyItem  
SET IsActive = 0
FROM (SELECT RHI.ReportingHierarchyItemID as RHIID, DEP.PositionCode AS DEPPOS
FROM MASTER.ReportingHierarchyItem RHI
LEFT JOIN INTEGRATION.ingress_DimEmployeePosition DEP 
ON DEP.PositionCode =RHI.ItemCode) AS j
WHERE DEPPOS IS NULL

GO
