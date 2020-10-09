SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE VIEW [ACCESS].[vw_ReportingHierarchyUserAccessWithLevels] AS

   WITH cte
   AS
		(
			SELECT	rep.CompanyID
					, rep.ReportingHierarchyTypeID
					, rep.ItemCode
					, rep. ItemName
					, CONVERT(VARCHAR(50), NULL) AS LevelItemCode
					, CONVERT(VARCHAR(100), NULL) AS LevelItemName
					, rep.ReportingHierarchyItemID
					, rep.ParentItemID 
					, rep.UserHierarchyLevel
					, rep.PersonID
					, rep.IsDefaultHierarchyItem
					, rep.ReportingHierarchySortOrder
					, CONVERT(int, 0) AS LevelSortOrder
					, 0 AS IsFullAccessUser
			FROM	[ACCESS].[vw_ReportingHierarchyUserAccess] rep
			where	rep.PersonID IS NOT NULL
				
			--where	UserHierarchyLevel = 1

			UNION ALL

			SELECT	rep2.CompanyID
					, rep2.ReportingHierarchyTypeID
					, repcte.ItemCode
					, repcte.ItemName
					, rep2.ItemCode as LevelItemCode
					, rep2.ItemName as LevelItemName
					, rep2.ReportingHierarchyItemID
					, rep2.ParentItemID
					, rep2.UserHierarchyLevel
					, rep2.PersonID
					, rep2.IsDefaultHierarchyItem
					, repcte.ReportingHierarchySortOrder
					, rep2.ReportingHierarchySortOrder AS LevelSortOrder
					, 0 AS IsFullAccessUser
			FROM	[ACCESS].[vw_ReportingHierarchyUserAccess] rep2
					INNER JOIN cte repcte ON repcte.ParentItemID = rep2.ReportingHierarchyItemID
		    where  rep2.Personid IS NOT NULL
   )
   SELECT	CompanyID,
			ReportingHierarchyTypeID,
			-- ItemCode,
			MAX(ReportingHierarchyItemID) as ReportingHierarchyItemID,
			MAX(UserHierarchyLevel) AS UserHierarchyLevel,
			PersonID,
			IsDefaultHierarchyItem, 
			IsFullAccessUser,
			CASE WHEN MAX(UserhierarchyLevel) = 1 THEN MAX(ItemName) ELSE MAX(L1) END AS L1,
			CASE WHEN MAX(UserhierarchyLevel) = 2 THEN MAX(ItemName) ELSE MAX(L2) END AS L2,
			CASE WHEN MAX(UserhierarchyLevel) = 3 THEN MAX(ItemName) ELSE MAX(L3) END AS L3,
			CASE WHEN MAX(UserhierarchyLevel) = 4 THEN MAX(ItemName) ELSE MAX(L4) END AS L4,
			CASE WHEN MAX(UserhierarchyLevel) = 5 THEN MAX(ItemName) ELSE MAX(L5) END AS L5,
			CASE WHEN MAX(UserhierarchyLevel) = 6 THEN MAX(ItemName) ELSE MAX(L6) END AS L6,
			CASE WHEN MAX(UserhierarchyLevel) = 7 THEN MAX(ItemName) ELSE MAX(L7) END AS L7,
			CASE WHEN MAX(UserhierarchyLevel) = 8 THEN MAX(ItemName) ELSE MAX(L8) END AS L8,
			CASE WHEN MAX(UserhierarchyLevel) = 9 THEN MAX(ItemName) ELSE MAX(L9) END AS L9,
			CASE WHEN MAX(UserhierarchyLevel) = 10 THEN MAX(ItemName) ELSE MAX(L10) END AS L10,

			CASE WHEN MAX(UserhierarchyLevel) = 1 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L1SortOrder) END AS L1SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 2 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L2SortOrder) END AS L2SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 3 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L3SortOrder) END AS L3SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 4 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L4SortOrder) END AS L4SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 5 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L5SortOrder) END AS L5SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 6 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L6SortOrder) END AS L6SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 7 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L7SortOrder) END AS L7SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 8 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L8SortOrder) END AS L8SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 9 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L9SortOrder) END AS L9SortOrder,
			CASE WHEN MAX(UserhierarchyLevel) = 10 THEN MAX(ReportingHierarchySortOrder) ELSE MAX(L10SortOrder) END AS L10SortOrder
	  FROM (
			SELECT	cte.CompanyID,
					cte.ReportingHierarchyTypeID,
					cte.ItemCode,
					cte.ItemName,
					cte.ReportingHierarchyItemID,
					cte.UserHierarchyLevel,
					cte.PersonID,
					cte.IsDefaultHierarchyItem,
					cte.IsFullAccessUser,
					CASE WHEN cte.UserHierarchyLevel = 1 THEN LevelItemName ELSE NULL END AS L1,
					CASE WHEN cte.UserHierarchyLevel = 2 THEN LevelItemName ELSE NULL END AS L2,
					CASE WHEN cte.UserHierarchyLevel = 3 THEN LevelItemName ELSE NULL END AS L3,
					CASE WHEN cte.UserHierarchyLevel = 4 THEN LevelItemName ELSE NULL END AS L4,
					CASE WHEN cte.UserHierarchyLevel = 5 THEN LevelItemName ELSE NULL END AS L5,
					CASE WHEN cte.UserHierarchyLevel = 6 THEN LevelItemName ELSE NULL END AS L6,
					CASE WHEN cte.UserHierarchyLevel = 7 THEN LevelItemName ELSE NULL END AS L7,
					CASE WHEN cte.UserHierarchyLevel = 8 THEN LevelItemName ELSE NULL END AS L8,
					CASE WHEN cte.UserHierarchyLevel = 9 THEN LevelItemName ELSE NULL END AS L9,
					CASE WHEN cte.UserHierarchyLevel = 10 THEN LevelItemName ELSE NULL END AS L10,

					CASE WHEN cte.UserHierarchyLevel = 1 THEN LevelSortOrder ELSE NULL END AS L1SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 2 THEN LevelSortOrder ELSE NULL END AS L2SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 3 THEN LevelSortOrder ELSE NULL END AS L3SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 4 THEN LevelSortOrder ELSE NULL END AS L4SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 5 THEN LevelSortOrder ELSE NULL END AS L5SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 6 THEN LevelSortOrder ELSE NULL END AS L6SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 7 THEN LevelSortOrder ELSE NULL END AS L7SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 8 THEN LevelSortOrder ELSE NULL END AS L8SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 9 THEN LevelSortOrder ELSE NULL END AS L9SortOrder,
					CASE WHEN cte.UserHierarchyLevel = 10 THEN LevelSortOrder ELSE NULL END AS L10SortOrder,
					cte.ReportingHierarchySortOrder
			  FROM	cte
			) a
	GROUP BY CompanyID, ReportingHierarchyTypeID, ItemCode, PersonID, IsDefaultHierarchyItem, IsFullAccessUser, ReportingHierarchySortOrder
	--Order by UserHierarchyLevel

	union all

	select 	*
	from	[ACCESS].[vw_ReportingHierarchyFullUserAccessWithLevels]


GO
