SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

--Sample execution
--EXEC [MASTER].[sp_get_ReportingHierarchyByUser] 'THARISA\tjohnson', 2

CREATE PROCEDURE [MASTER].[sp_get_ReportingHierarchyByUser]
	@UserDomainName VARCHAR(200),
	@ReportingHierarchyTypeID INT

AS

	--Get report position ID
	DECLARE @PersonAccessControlListID INT
	SET @PersonAccessControlListID = (SELECT [ACCESS].udf_GetPersonAccessControllistFromDomainAccount(@UserDomainName))

    ;WITH cte_ReportingHierarchy 
    AS
		(
			SELECT	rep.ReportingHierarchyItemID
					, rep.ItemCode
				    , rep.ItemName
					, rep.ReportingHierarchyTypeID
					, CONVERT(INT, NULL) AS ParentItemID
					, 1 AS HierarchyLevel
			FROM	[MASTER].ReportingHierarchyItem rep
				    INNER JOIN [ACCESS].[ReportingHierarchyUserAccess] RHUA ON
						RHUA.ReportingHierarchyItemID = rep.ReportingHierarchyItemID
			WHERE	rep.ReportingHierarchyTypeID = @ReportingHierarchyTypeID AND
				    RHUA.PersonAccessControlListID = @PersonAccessControlListID


			UNION ALL

			SELECT	rep2.ReportingHierarchyItemID
					, rep2.ItemCode
				    , rep2.ItemName
					, rep2.ReportingHierarchyTypeID
					, rep2.ParentItemID
					, repcte.HierarchyLevel + 1 AS HierarchyLevel
			FROM	[MASTER].ReportingHierarchyItem rep2
					INNER JOIN cte_ReportingHierarchy repcte ON
						repcte.ReportingHierarchyItemID = rep2.ParentItemID
   )
	SELECT	cte.ReportingHierarchyItemID,
			cte.ItemCode,
			cte.ItemName,
			cte.ReportingHierarchyTypeID,
			cte.ParentItemID,
			cte.HierarchyLevel,
			comb.BusinessKey
	FROM	cte_ReportingHierarchy cte
			INNER JOIN [MASTER].LinkReportingHierarchyItemToBKCombination link ON
				link.ReportingHierarchyItemID = cte.ReportingHierarchyItemID
			INNER JOIN [MASTER].[LinkBKCombination] comb ON
				comb.LinkID = link.LinkID

GO
