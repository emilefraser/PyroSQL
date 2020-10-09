SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

-- =============================================
-- Author:  Wium Swart
-- Create Date: 4 June 2019
-- Description: Stored Proc that fills PersonAccessContrlList
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_PersonAccessControlList]

AS

-- Fill the PersonAccessControlList Table 
  INSERT INTO [ACCESS].PersonAccessControlList 
        (OrgChartPositionID, 
		 PersonNonEmployeeID, 
		 CreatedDT,
		 IsActive)
  SELECT OCP.OrgChartPositionID, 
         PNE.PersonNonEmployeeID, 
		 GETDATE() as CreatedDT,
		 OCP.IsActive
  FROM [GOV].OrgChartPosition OCP 
  LEFT JOIN [GOV].PersonNonEmployee PNE ON PNE.ReportsToOrgChartPositionID = OCP.ReportsToOrgChartPositionID
  LEFT JOIN [ACCESS].PersonAccessControlList PACL ON PACL.OrgChartPositionID = OCP.OrgChartPositionID 
  WHERE PACL.PersonAccessControlListID IS NULL

  UPDATE [ACCESS].PersonAccessControlList
  SET IsActive = OCP.IsActive
  FROM [ACCESS].PersonAccessControlList PACL
  LEFT JOIN GOV.OrgChartPosition OCP ON OCP.OrgchartPositionID = PACL.OrgchartPositionID
  WHERE PACL.IsActive != OCP.IsActive


  -- ******    LOOK AT WHEN PERSONNONEMPLOYEE IS ADDED TO THE ROLE BASED HEIRARCHY ****** THIS UPDATE MUST ACCOUNT FOR THE FACT THAT CHANGES CAN OCCUR IN THE ORG CHART
  /*    
  -- Update the PersonAccessControlList Table where there have been changes
  UPDATE [ACCESS].PersonAccessControlList 
   SET PersonNonEmployeeID = UPDATES.PersonNonEmployeeID
  FROM(  Select OCP.OrgChartPositionID, PNE.PersonNonEmployeeID,GETDATE() as CreatedDT
  from [GOV].OrgChartPosition OCP 
  LEFT JOIN [GOV].PersonNonEmployee PNE ON PNE.ReportsToOrgChartPositionID = OCP.ReportsToOrgChartPositionID) UPDATES
  LEFT JOIN [ACCESS].PersonAccessControlList PACL ON PACL.OrgChartPositionID = UPDATES.OrgchartPositionID
  WHERE PACL.PersonNonEmployeeID != UPDATES.PersonNonEmployeeID
  --the update statement will occur even if the records on OCP are out of sync
  */

GO
