SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [ACCESS].[vw_ReportingHierarchyUserAccessDetailed]
AS
/*
SELECT        RHUA.ReportingHierarchyUserAccessID,
			  RHUA.ReportingHierarchyItemID, 
			  RHUA.PersonAccessControlListID, 
			  RHUA.IsDefaultHierarchyItem, 
			  RHUA.CreatedDT, 
			  RHUA.UpdatedDT, 
			  RHUA.IsActive, 
			  RP.EmployeePositionID, 
              MASTER.ReportingHierarchyItem.ReportingHierarchyTypeID
FROM            ACCESS.ReportingHierarchyUserAccess AS RHUA 
			    INNER JOIN ACCESS.PersonAccessControlList AS RP ON RHUA.PersonAccessControlListID = RP.PersonAccessControlListID 
				INNER JOIN MASTER.ReportingHierarchyItem ON RHUA.ReportingHierarchyItemID = MASTER.ReportingHierarchyItem.ReportingHierarchyItemID
				*/
SELECT        RHUA.ReportingHierarchyUserAccessID,
			  RHUA.ReportingHierarchyItemID, 
			  RHUA.PersonAccessControlListID, 
			  RHUA.IsDefaultHierarchyItem, 
			  RHUA.CreatedDT, 
			  RHUA.UpdatedDT, 
			  RHUA.IsActive, 
			  PACL.OrgChartPositionID, 
              MASTER.ReportingHierarchyItem.ReportingHierarchyTypeID
FROM            ACCESS.ReportingHierarchyUserAccess AS RHUA 
			    INNER JOIN ACCESS.PersonAccessControlList AS PACL ON RHUA.PersonAccessControlListID = PACL.PersonAccessControlListID 
				INNER JOIN MASTER.ReportingHierarchyItem ON RHUA.ReportingHierarchyItemID = MASTER.ReportingHierarchyItem.ReportingHierarchyItemID

GO
