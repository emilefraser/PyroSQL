SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE view [MASTER].[vw_mat_OrgChartPositionReporting]
as


select ocp.OrgChartPositionID, ocp.ReportsToOrgChartPositionID, ocp.PositionDescription, rht.ReportingHierarchyTypeID, rht.reportinghierarchytypename
from gov.orgchartposition ocp
LEFT JOIN ACCESS.PersonAccessControlList pacl on pacl.orgchartpositionid = ocp.orgchartpositionid
LEFT JOIN ACCESS.ReportingHierarchyUserAccess RHUA ON RHUA.PersonaccesscontrollistID = pacl.PersonaccesscontrollistID
LEFT JOIN master.reportinghierarchyitem RHI ON RHI.ReportingHierarchyItemID = RHUA.ReportingHierarchyItemID
LEFT JOIN master.reportinghierarchytype rht ON rht.ReportingHierarchyTypeID = RHI.ReportingHierarchyTypeID






GO
