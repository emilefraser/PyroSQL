SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON










CREATE view [MASTER].[vw_ReportingHierarchy] AS

   WITH cte_ReportingHierarchy 
   AS
		(
			SELECT	rep.CompanyID
					, rep.ReportingHierarchyItemID
					, rep.ItemCode
				    , rep.ItemName
					, rep.ReportingHierarchyTypeID
					, CONVERT(INT, NULL) AS ParentItemID
					, 1 AS HierarchyLevel
					, rep.ReportingHierarchySortOrder
			FROM	[MASTER].ReportingHierarchyItem rep
			WHERE	rep.ParentItemID IS NULL


			UNION ALL

			SELECT	repcte.CompanyID
					, rep2.ReportingHierarchyItemID
					, rep2.ItemCode
				    , rep2.ItemName
					, rep2.ReportingHierarchyTypeID
					, rep2.ParentItemID
					, repcte.HierarchyLevel + 1 AS HierarchyLevel
					, rep2.ReportingHierarchySortOrder
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
			cte.HierarchyLevel,
			cte.ReportingHierarchySortOrder
	FROM	cte_ReportingHierarchy cte
			--INNER JOIN [MASTER].LinkReportingHierarchyItemToBusinessEntity link ON
			--	link.ReportingHierarchyItemID = cte.ReportingHierarchyItemID
	--WHERE cte.ReportingHierarchyTypeID IN (2, 6,18)


GO
