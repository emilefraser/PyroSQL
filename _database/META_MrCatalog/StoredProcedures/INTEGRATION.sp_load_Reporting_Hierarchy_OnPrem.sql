SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 6 Oct 2018
-- Description: Loads the data catalog tables from the INTEGRATION table.
-- =============================================
CREATE PROCEDURE [INTEGRATION].[sp_load_Reporting_Hierarchy_OnPrem]
AS


insert into  [DataManager_Local].[ACCESS].[ReportingHierarchyUserAccess]
Select * from [ACCESS].[vw_ReportingHierarchyAccess]


GO
