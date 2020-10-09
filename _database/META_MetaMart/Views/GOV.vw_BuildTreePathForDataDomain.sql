SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON







CREATE VIEW [GOV].[vw_BuildTreePathForDataDomain]
AS

WITH EntitiesCTE(DataDomainID, DataDomainCode, DataDomainDescription, Parent, Level, UltimateParent, HasChildren, Treepath, IsActive) AS
	( SELECT	dd.DataDomainID,
				dd.DataDomainCode,
			    dd.DataDomainDescription,
				dd.DataDomainParentID, 
				0 AS Level,
				dd.DataDomainID as UltimateParent,
				CASE
					WHEN dd.DataDomainID in (select t.DataDomainParentID FROM GOV.DataDomain t) THEN 1
					ELSE 0
				END AS HasChildren,
				CAST(dd.DataDomainCode AS VARCHAR(1024)) AS Treepath,
				dd.IsActive
	  FROM GOV.DataDomain dd
	  WHERE dd.DataDomainParentID is null

	  UNION ALL --recursive

		SELECT	dd3.DataDomainID,
				dd3.DataDomainCode,
				dd3.DataDomainDescription, 
				dd3.DataDomainParentID,
				EntitiesCTE.Level + 1 AS Level,
				EntitiesCTE.UltimateParent,
				CASE
					WHEN dd3.DataDomainID in (select t.DataDomainParentID FROM GOV.DataDomain t) THEN 1
					ELSE 0
				END AS HasChildren,
				CAST(EntitiesCTE.treepath + ' -> ' + CAST(dd3.DataDomainCode AS VARCHAR(1024)) AS VARCHAR(1024)) AS treepath,
				dd3.IsActive
	  FROM GOV.DataDomain dd3
	  INNER JOIN EntitiesCTE
			ON EntitiesCTE.DataDomainID = dd3.DataDomainParentID
			)

SELECT 
	a.*--,
	--b.DataDomainCode,
	--b.DataDomainDescription


	FROM EntitiesCTE a
INNER JOIN 
	GOV.DataDomain b
	ON  b.DataDomainID = a.DataDomainID


GO
