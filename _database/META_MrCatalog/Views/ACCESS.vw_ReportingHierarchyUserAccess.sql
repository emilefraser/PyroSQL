SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







CREATE VIEW [ACCESS].[vw_ReportingHierarchyUserAccess] AS
   WITH cte_ReportingHierarchy 
   AS
		(
		/*
			SELECT	RH.CompanyID
					, RH.ReportingHierarchyItemID
					, RH.ItemCode
					, RH.ItemName
					, RH.ReportingHierarchyTypeID
					, RH.ParentItemID
					, RU.ReportUserID
					, MIN(RH.HierarchyLevel) AS MinHierarchyLevel
					, 1 AS UserHierarchyLevel
					, RHUA.IsDefaultHierarchyItem
					, RH.ReportingHierarchySortOrder
					--, 0 AS IsFullAccessUser
			FROM	[MASTER].[vw_ReportingHierarchy] RH
					LEFT JOIN	[ACCESS].[ReportingHierarchyUserAccess] RHUA ON RHUA.ReportingHierarchyItemID = RH.ReportingHierarchyItemID
					LEFT JOIN	[ACCESS].[ReportPosition] RP ON RP.ReportPositionID = RHUA.PersonAccessControlListID--ReportPositionID
					LEFT JOIN	[SOURCELINK].[EmployeePosition] EP ON EP.EmployeePositionID = RP.EmployeePositionID
					LEFT JOIN	[SOURCELINK].[Employee] E ON E.EmployeeID = EP.EmployeeID
					LEFT JOIN	[ACCESS].[ReportUser] RU ON RU.EmployeeID = E.EmployeeID
					*/
--*****************************************************  ws: all works
			SELECT	RH.CompanyID
					, RH.ReportingHierarchyItemID
					, RH.ItemCode
					, RH.ItemName
					, RH.ReportingHierarchyTypeID
					, RH.ParentItemID
					, P.PersonID
					, MIN(RH.HierarchyLevel) AS MinHierarchyLevel
					, 1 AS UserHierarchyLevel
					, RHUA.IsDefaultHierarchyItem
					, RH.ReportingHierarchySortOrder
					--, 0 AS IsFullAccessUser
			FROM	[MASTER].[vw_ReportingHierarchy] RH
					LEFT JOIN	[ACCESS].[ReportingHierarchyUserAccess] RHUA ON RHUA.ReportingHierarchyItemID = RH.ReportingHierarchyItemID
					LEFT JOIN	[ACCESS].[PersonAccessControlList] PACL ON PACL.PersonAccessControlListID = RHUA.PersonAccessControlListID
					LEFT JOIN	[GOV].[OrgChartPosition] OCP ON OCP.OrgChartPositionID = PACL.OrgChartPositionID
					LEFT JOIN	[GOV].[PersonEmployee] PE ON PE.PersonEmployeeID = OCP.PersonEmployeeID
					LEFT JOIN	[GOV].[Person] P ON P.PersonID = PE.PersonID
--*****************************************************
			WHERE	1=1
					--and RH.ReportingHierarchyTypeID IN (2, 6) --TODO To remove so all hierarchy types show
					--AND RU.ReportUserID IN (5,19, 24, 39) --TODO To remove so all users show
					--RH.ItemCode IN ('PROC', 'MIN', 'RandD')
			GROUP BY RH.CompanyID
					, RH.ReportingHierarchyItemID
					, RH.ItemCode
					, RH.ItemName
					, RH.ReportingHierarchyTypeID
					, RH.ParentItemID
					, P.PersonID
					, RHUA.IsDefaultHierarchyItem
					, RH.ReportingHierarchySortOrder
			
			UNION ALL

			SELECT	repcte.CompanyID
					, rep2.ReportingHierarchyItemID
					, rep2.ItemCode
				    , rep2.ItemName
					, rep2.ReportingHierarchyTypeID
					, rep2.ParentItemID
					, repcte.PersonID
					, NULL AS MinHierarchyLevel
					, repcte.UserHierarchyLevel + 1 AS UserHierarchyLevel
					, repcte.IsDefaultHierarchyItem
					, rep2.ReportingHierarchySortOrder
					--, 0 AS IsFullAccessUser
			FROM	[MASTER].ReportingHierarchyItem rep2
					INNER JOIN cte_ReportingHierarchy repcte ON
						repcte.ReportingHierarchyItemID = rep2.ParentItemID
					
   )
	SELECT	cte.CompanyID,
			cte.ReportingHierarchyItemID,
			cte.ItemCode,
			cte.ItemName,
			cte.ReportingHierarchyTypeID,
			cte.ParentItemID,
			cte.PersonID,
			cte.UserHierarchyLevel
			,cte.IsDefaultHierarchyItem
			,cte.ReportingHierarchySortOrder
			--,cte.IsFullAccessUser
	FROM	cte_ReportingHierarchy cte



GO
