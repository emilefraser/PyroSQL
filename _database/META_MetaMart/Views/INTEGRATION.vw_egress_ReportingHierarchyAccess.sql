SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE VIEW [INTEGRATION].[vw_egress_ReportingHierarchyAccess] AS
/*
SELECT	 '' AS HashKey, RHT.ReportingHierarchyTypeCode, RHT.ReportingHierarchyTypeName --come back
		,RHI.ItemCode, RHI.ItemName
		,RHIP.ItemCode ParentItemCode, RHIP.ItemName as ParentItemName
		,LBKC.BusinessKey, LBKC.LinkID
		,LBKC.DataCatalogFieldID, F.FieldName
		, RHUA.IsDefaultHierarchyItem ,RU.DomainAccount
FROM	[MASTER].[ReportingHierarchyType] RHT
	LEFT JOIN	[MASTER].[ReportingHierarchyItem] RHI ON RHI.ReportingHierarchyTypeID = RHT.ReportingHierarchyTypeID
	LEFT JOIN	[MASTER].[LinkReportingHierarchyItemToBKCombination] LRHI ON RHI.ReportingHierarchyItemID = LRHI.ReportingHierarchyItemID
	LEFT JOIN	[MASTER].[LinkBKCombination] LBKC ON LRHI.LinkID = LBKC.LinkID
	LEFT JOIN	[DC].[Field] F ON LBKC.DataCatalogFieldID = F.FieldID
	LEFT JOIN	[MASTER].[ReportingHierarchyItem] RHIP ON RHI.ParentItemID = RHIP.ReportingHierarchyItemID
	LEFT JOIN	[ACCESS].[ReportingHierarchyUserAccess] RHUA ON RHUA.ReportingHierarchyItemID = RHI.ReportingHierarchyItemID
	LEFT JOIN	[ACCESS].[PersonAccessControlList] RP ON RP.ReportPositionID = RHUA.ReportPositionID
	LEFT JOIN	[SOURCELINK].[EmployeePosition] EP ON EP.EmployeePositionID = RP.EmployeePositionID
	LEFT JOIN	[SOURCELINK].[Employee] E ON E.EmployeeID = EP.EmployeeID
	LEFT JOIN	[ACCESS].[ReportUser] RU ON RU.EmployeeID = E.EmployeeID
--WHERE	RHT.ReportingHierarchyTypeCode = 'PRODREP'
--WHERE RHI.ItemName = 'Voyager'
*/
--*********************************************************************** ws:WORKS
SELECT	 '' AS HashKey, RHT.ReportingHierarchyTypeCode, RHT.ReportingHierarchyTypeName 
		,RHI.ItemCode, RHI.ItemName
		,RHIP.ItemCode ParentItemCode, RHIP.ItemName as ParentItemName
		,LBKC.BusinessKey, LBKC.LinkID
		,LBKC.DataCatalogFieldID, F.FieldName
		, RHUA.IsDefaultHierarchyItem ,P.DomainAccountName
FROM	[MASTER].[ReportingHierarchyType] RHT
	LEFT JOIN	[MASTER].[ReportingHierarchyItem] RHI ON RHI.ReportingHierarchyTypeID = RHT.ReportingHierarchyTypeID
	LEFT JOIN	[MASTER].[LinkReportingHierarchyItemToBKCombination] LRHI ON RHI.ReportingHierarchyItemID = LRHI.ReportingHierarchyItemID
	LEFT JOIN	[MASTER].[LinkBKCombination] LBKC ON LRHI.LinkID = LBKC.LinkID
	LEFT JOIN	[DC].[Field] F ON LBKC.DataCatalogFieldID = F.FieldID
	LEFT JOIN	[MASTER].[ReportingHierarchyItem] RHIP ON RHI.ParentItemID = RHIP.ReportingHierarchyItemID
	LEFT JOIN	[ACCESS].[ReportingHierarchyUserAccess] RHUA ON RHUA.ReportingHierarchyItemID = RHI.ReportingHierarchyItemID
	LEFT JOIN	[ACCESS].[PersonAccessControlList] PACL ON PACL.PersonAccessControlListID = RHUA.PersonAccessControlListID
	LEFT JOIN	[GOV].[OrgChartPosition] OCP ON OCP.OrgChartPositionID = PACL.OrgChartPositionID
	LEFT JOIN	[GOV].[PersonEmployee] PE ON PE.PersonEmployeeID = OCP.PersonEmployeeID
	LEFT JOIN	[GOV].[Person] P ON P.PersonID = PE.PersonID
	--WHERE	RHT.ReportingHierarchyTypeCode = 'PRODREP'
    --WHERE RHI.ItemName = 'Voyager'
--**********************************************************************





GO
