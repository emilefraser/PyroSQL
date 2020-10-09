SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
-- =============================================
-- Author: Wium Swart
-- Create Date: 6 June
-- Description: Inserts into and updates the ACCESS.ReportingHierarchyUserAccess
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_ReportingHierarchyUserAccess]

AS
INSERT INTO ACCESS.ReportingHierarchyUserAccess
      ([ReportingHierarchyItemID]
      ,[PersonAccessControlListID]
      ,[IsDefaultHierarchyItem]
      ,[CreatedDT]
      ,[UpdatedDT]
      ,[IsActive])
SELECT 
       RHI.ReportingHierarchyItemID
      ,PACL.PersonAccessControlListID
      , 1
      , GETDATE()
      ,NULL
      ,OCP.IsActive
FROM MASTER.ReportingHierarchyItem RHI
LEFT JOIN GOV.OrgChartPosition OCP ON OCP.PositionCode = RHI.ItemCode
LEFT JOIN ACCESS.PersonAccessControlList PACL ON PACL.OrgChartPositionID = OCP.OrgChartPositionID
LEFT JOIN ACCESS.ReportingHierarchyUserAccess RHUA ON RHUA.ReportingHierarchyItemID = RHI.ReportingHierarchyItemID
WHERE RHUA.ReportingHierarchyItemID IS NULL




--RUN UPDATE STATEMENT SEE THAT SAME 4 RECORDS KEEP GETTING UPDATED

UPDATE ACCESS.ReportingHierarchyUserAccess
SET 
       [ReportingHierarchyItemID] = RHI.ReportingHierarchyItemID
      ,[PersonAccessControlListID] = PACL.PersonAccessControlListID
      --,[IsDefaultHierarchyItem] = -due to it being a hard coded value
      ,[UpdatedDT] = GETDATE()
      ,[IsActive] = OCP.IsActive
FROM ACCESS.ReportingHierarchyUserAccess RHUA
LEFT JOIN MASTER.ReportingHierarchyItem RHI ON RHI.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID
LEFT JOIN GOV.OrgChartPosition OCP ON OCP.PositionCode = RHI.ItemCode
LEFT JOIN ACCESS.PersonAccessControlList PACL ON PACL.OrgChartPositionID = OCP.OrgChartPositionID
WHERE 
      RHUA.[ReportingHierarchyItemID] != RHI.ReportingHierarchyItemID
	  OR
      RHUA.[PersonAccessControlListID] != PACL.PersonAccessControlListID
	  OR
      --,[IsDefaultHierarchyItem] 
      RHUA.[IsActive] != OCP.IsActive OR RHUA.[IsActive] IS NULL

GO
