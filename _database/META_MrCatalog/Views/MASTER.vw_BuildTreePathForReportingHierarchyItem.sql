SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON




CREATE VIEW [MASTER].[vw_BuildTreePathForReportingHierarchyItem]
AS
        WITH EntitiesCTE(ReportingHierarchyTypeID, ReportingHierarchyTypeCode, ReportingHierarchyItemID, SortOrder, Parent, Level, UltimateParent, HasChildren, Treepath, CreatedDT, UpdatedDT, IsActive, ReportingHierarchySortOrder, ReportingHierarchySortOrderPath, Shown, Expanded) AS
    ( SELECT    RHT.ReportingHierarchyTypeID,
                RHT.ReportingHierarchyTypeCode,
                RHI.ReportingHierarchyItemID AS id,
				RHI.ReportingHierarchySortOrder AS SortOrder,
                RHI.ParentItemID, 
                0 AS Level,
                RHI.ReportingHierarchyItemID as UltimateParent,
                CASE
                    WHEN RHI.ReportingHierarchyItemID in (select t.ParentItemID FROM MASTER.ReportingHierarchyItem t) THEN 1
                    ELSE 0
                END AS HasChildren,
                CAST(RHI.ItemCode AS VARCHAR(1024)) AS Treepath,
				RHI.CreatedDT,
				RHI.UpdatedDT,
                RHI.IsActive,
                RHI.ReportingHierarchySortOrder,
                CAST(RHI.ReportingHierarchySortOrder + 10000 AS varchar(1024)) AS ReportingHierarchySortOrderPath,
				1 AS Shown,
				1 AS Expanded
      FROM MASTER.ReportingHierarchyItem RHI
      INNER JOIN  MASTER.ReportingHierarchyType RHT
      on RHI.ReportingHierarchyTypeID = RHT.ReportingHierarchyTypeID
      WHERE RHI.ParentItemID is null
 
      UNION ALL --recursive
 
        SELECT    RHT.ReportingHierarchyTypeID,
                RHT.ReportingHierarchyTypeCode,
                RHI.ReportingHierarchyItemID AS id,
				RHI.ReportingHierarchySortOrder AS SortOrder, 
                RHI.ParentItemID,
                EntitiesCTE.Level + 1 AS Level,
                EntitiesCTE.UltimateParent,
                CASE
                    WHEN RHI.ReportingHierarchyItemID in (select t.ParentItemID FROM MASTER.ReportingHierarchyItem t) THEN 1
                    ELSE 0
                END AS HasChildren,
                CAST(EntitiesCTE.treepath + ' -> ' + CAST(RHI.ItemCode AS VARCHAR(1024)) AS VARCHAR(1024)) AS treepath,
				RHI.CreatedDT,
				RHI.UpdatedDT,
                RHI.IsActive,
                RHI.ReportingHierarchySortOrder,
                CAST(EntitiesCTE.ReportingHierarchySortOrderPath + ' -> ' + CAST(RHI.ReportingHierarchySortOrder + ((level + 2) * 10000) AS varchar(1024)) AS varchar(1024)) AS ReportingHierarchySortOrderPath,
				1 AS Shown,
				1 AS Expanded
	  FROM MASTER.ReportingHierarchyItem RHI
      INNER JOIN  MASTER.ReportingHierarchyType RHT
      on RHI.ReportingHierarchyTypeID = RHT.ReportingHierarchyTypeID
      INNER JOIN EntitiesCTE
            ON EntitiesCTE.ReportingHierarchyItemID = RHI.ParentItemID
            )
 
SELECT TOP(1000000)
    a.*
    ,b.ReportingHierarchyTypeName
    ,e.ItemCode
    ,e.ItemName
    ,e.ParentItemID
    ,e.CompanyID
--    ,e.ReportingHierarchySortOrder
 

    FROM EntitiesCTE a
 
INNER JOIN 
    MASTER.ReportingHierarchyType b
    ON  b.ReportingHierarchyTypeID = a.ReportingHierarchyTypeID
INNER JOIN MASTER.ReportingHierarchyItem e
    ON e.ReportingHierarchyItemID = a.ReportingHierarchyItemID
    WHERE a.ReportingHierarchyTypeID = e.ReportingHierarchyTypeID 
    ORDER BY a.ReportingHierarchySortOrderPath ASC

GO
