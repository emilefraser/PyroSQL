SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON





CREATE view [MASTER].[vw_ReportingHierarchyWithLevels]
AS

   WITH cte
   AS
		(
			SELECT	rep.CompanyID
					, rep.ReportingHierarchyTypeID
					, rep.ItemCode
					, CONVERT(VARCHAR(50), NULL) AS LevelItemCode
					--, rep.ParentItemCode
					, rep.ReportingHierarchyItemID
					, rep.ParentItemID
					, rep.HierarchyLevel
					--, rep.ReportingHierarchySortOrder
			FROM	[MASTER].[vw_ReportingHierarchy] rep

			UNION ALL

			SELECT	repcte.CompanyID
					, rep2.ReportingHierarchyTypeID
					, repcte.ItemCode
					, rep2.ItemCode AS LevelItemCode
					--, rep2.ReportsToPosCode
					, rep2.ReportingHierarchyItemID
					, rep2.ParentItemID
					, rep2.HierarchyLevel
					--, rep2.ReportingHierarchySortOrder
			FROM	[MASTER].[vw_ReportingHierarchy] rep2
					INNER JOIN cte repcte ON repcte.ParentItemID = rep2.ReportingHierarchyItemID

   )
	SELECT CompanyID,
		   ReportingHierarchyTypeID,
		   ItemCode,
		   --ReportingHierarchySortOrder,
		   MAX(HierarchyLevel) AS HierarchyLevel,
		   MAX(L1) AS L1,
		   MAX(L2) AS L2,
		   MAX(L3) AS L3,
		   MAX(L4) AS L4,
		   MAX(L5) AS L5,
		   MAX(L6) AS L6,
		   MAX(L7) AS L7,
		   MAX(L8) AS L8,
		   MAX(L9) AS L9,
		   MAX(L10) AS L10
	  FROM (
			SELECT	cte.CompanyID,
					cte.ReportingHierarchyTypeID,
					cte.ItemCode,
					cte.HierarchyLevel,
					--cte.ReportingHierarchySortOrder,
					CASE WHEN cte.HierarchyLevel = 1 THEN LevelItemCode ELSE NULL END AS L1,
					CASE WHEN cte.HierarchyLevel = 2 THEN LevelItemCode ELSE NULL END AS L2,
					CASE WHEN cte.HierarchyLevel = 3 THEN LevelItemCode ELSE NULL END AS L3,
					CASE WHEN cte.HierarchyLevel = 4 THEN LevelItemCode ELSE NULL END AS L4,
					CASE WHEN cte.HierarchyLevel = 5 THEN LevelItemCode ELSE NULL END AS L5,
					CASE WHEN cte.HierarchyLevel = 6 THEN LevelItemCode ELSE NULL END AS L6,
					CASE WHEN cte.HierarchyLevel = 7 THEN LevelItemCode ELSE NULL END AS L7,
					CASE WHEN cte.HierarchyLevel = 8 THEN LevelItemCode ELSE NULL END AS L8,
					CASE WHEN cte.HierarchyLevel = 9 THEN LevelItemCode ELSE NULL END AS L9,
					CASE WHEN cte.HierarchyLevel = 10 THEN LevelItemCode ELSE NULL END AS L10

			  FROM	cte
			) a
	GROUP BY CompanyID, ReportingHierarchyTypeID, ItemCode
		--, ReportingHierarchySortOrder


GO
