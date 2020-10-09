SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON






CREATE VIEW [ACCESS].[vw_ReportingHierarchyFullUserAccessWithLevels]
AS
WITH cte_full
	AS
		(
			SELECT	CompanyID
					, ReportingHierarchyTypeID
					, RH.ItemCode
					, RH.ItemName
					, CONVERT(VARCHAR(50), NULL) AS LevelItemCode
					, CONVERT(VARCHAR(100), NULL) AS LevelItemName
					, RH.ReportingHierarchyItemID
					, RH.ParentItemID
					, RH.HierarchyLevel
					, NULL AS PersonID
					, 1 AS IsDefaultHierarchyItem
					, RH.ReportingHierarchySortOrder
					, CONVERT(int, 0) AS LevelSortOrder
					, 1 AS IsFullAccessUser
			FROM	[MASTER].[vw_ReportingHierarchy] RH
			WHERE	1=1
					and RH.ReportingHierarchyTypeID IN (2, 6) --TODO To remove so all hierarchy types show
					--AND RH.ReportUserID IS NULL --TODO To remove so all users show

			UNION ALL
			
			SELECT	repcte.CompanyID
					, RH.ReportingHierarchyTypeID
					, repcte.ItemCode
					, repcte.ItemName
					, RH.ItemCode AS LevelItemCode
					, RH.ItemName AS LevelItemName
					, RH.ReportingHierarchyItemID
					, RH.ParentItemID
					, RH.HierarchyLevel
					, NULL AS PersonID
					, 1 AS IsDefaultHierarchyItem
					, repcte.ReportingHierarchySortOrder
					, RH.ReportingHierarchySortOrder AS LevelSortOrder
					, 1 AS IsFullAccessUser
			FROM	[MASTER].[vw_ReportingHierarchy] RH
				INNER JOIN cte_full repcte ON repcte.ParentItemID = RH.ReportingHierarchyItemID
			WHERE	1=1
					and RH.ReportingHierarchyTypeID IN (2, 6) --TODO To remove so all hierarchy types show
					--and RH.ReportUserID IS NULL --TODO To remove so all users show
   )
	SELECT	CompanyID,
			ReportingHierarchyTypeID,
			-- ItemCode,
			MAX(ReportingHierarchyItemID) as ReportingHierarchyItemID,
			MAX(HierarchyLevel) AS HierarchyLevel,
			PersonID,
			IsDefaultHierarchyItem, 
			IsFullAccessUser,
			CASE WHEN MAX(HierarchyLevel) = 1 THEN MAX(ItemName) ELSE MAX(L1) END AS L1,
			CASE WHEN MAX(HierarchyLevel) = 2 THEN MAX(ItemName) ELSE MAX(L2) END AS L2,
			CASE WHEN MAX(HierarchyLevel) = 3 THEN MAX(ItemName) ELSE MAX(L3) END AS L3,
			CASE WHEN MAX(HierarchyLevel) = 4 THEN MAX(ItemName) ELSE MAX(L4) END AS L4,
			CASE WHEN MAX(HierarchyLevel) = 5 THEN MAX(ItemName) ELSE MAX(L5) END AS L5,
			CASE WHEN MAX(HierarchyLevel) = 6 THEN MAX(ItemName) ELSE MAX(L6) END AS L6,
			CASE WHEN MAX(HierarchyLevel) = 7 THEN MAX(ItemName) ELSE MAX(L7) END AS L7,
			CASE WHEN MAX(HierarchyLevel) = 8 THEN MAX(ItemName) ELSE MAX(L8) END AS L8,
			CASE WHEN MAX(HierarchyLevel) = 9 THEN MAX(ItemName) ELSE MAX(L9) END AS L9,
			CASE WHEN MAX(HierarchyLevel) = 10 THEN MAX(ItemName) ELSE MAX(L10) END AS L10,
						 
			CASE WHEN MAX(HierarchyLevel) = 1 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L1SortOrder) END AS L1SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 2 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L2SortOrder) END AS L2SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 3 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L3SortOrder) END AS L3SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 4 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L4SortOrder) END AS L4SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 5 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L5SortOrder) END AS L5SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 6 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L6SortOrder) END AS L6SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 7 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L7SortOrder) END AS L7SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 8 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L8SortOrder) END AS L8SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 9 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L9SortOrder) END AS L9SortOrder,
			CASE WHEN MAX(HierarchyLevel) = 10 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L10SortOrder) END AS L10SortOrder
	  FROM (
			SELECT	cte_full.CompanyID,
					cte_full.ReportingHierarchyTypeID,
					cte_full.ItemCode,
					cte_full.ItemName,
					cte_full.ReportingHierarchyItemID,
					cte_full.HierarchyLevel,
					cte_full.PersonID,
					cte_full.IsDefaultHierarchyItem,
					cte_full.IsFullAccessUser,
					CASE WHEN cte_full.HierarchyLevel = 1 THEN LevelItemName ELSE NULL END AS L1,
					CASE WHEN cte_full.HierarchyLevel = 2 THEN LevelItemName ELSE NULL END AS L2,
					CASE WHEN cte_full.HierarchyLevel = 3 THEN LevelItemName ELSE NULL END AS L3,
					CASE WHEN cte_full.HierarchyLevel = 4 THEN LevelItemName ELSE NULL END AS L4,
					CASE WHEN cte_full.HierarchyLevel = 5 THEN LevelItemName ELSE NULL END AS L5,
					CASE WHEN cte_full.HierarchyLevel = 6 THEN LevelItemName ELSE NULL END AS L6,
					CASE WHEN cte_full.HierarchyLevel = 7 THEN LevelItemName ELSE NULL END AS L7,
					CASE WHEN cte_full.HierarchyLevel = 8 THEN LevelItemName ELSE NULL END AS L8,
					CASE WHEN cte_full.HierarchyLevel = 9 THEN LevelItemName ELSE NULL END AS L9,
					CASE WHEN cte_full.HierarchyLevel = 10 THEN LevelItemName ELSE NULL END AS L10,

					CASE WHEN cte_full.HierarchyLevel = 1 THEN LevelSortOrder ELSE NULL END AS L1SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 2 THEN LevelSortOrder ELSE NULL END AS L2SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 3 THEN LevelSortOrder ELSE NULL END AS L3SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 4 THEN LevelSortOrder ELSE NULL END AS L4SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 5 THEN LevelSortOrder ELSE NULL END AS L5SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 6 THEN LevelSortOrder ELSE NULL END AS L6SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 7 THEN LevelSortOrder ELSE NULL END AS L7SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 8 THEN LevelSortOrder ELSE NULL END AS L8SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 9 THEN LevelSortOrder ELSE NULL END AS L9SortOrder,
					CASE WHEN cte_full.HierarchyLevel = 10 THEN LevelSortOrder ELSE NULL END AS L10SortOrder,
					cte_full.ReportingHierarchySortOrder
			  FROM	cte_full
			) a
	GROUP BY CompanyID,ReportingHierarchyTypeID, ItemCode, PersonID, IsDefaultHierarchyItem, IsFullAccessUser, ReportingHierarchySortOrder
	--Order by UserHierarchyLevel

GO
