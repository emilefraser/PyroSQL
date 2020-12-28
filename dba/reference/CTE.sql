--CREATE VIEW CTE.vw_BGTree
--AS 

WITH TreeCTE 
AS
(
SELECT 
	parent.BusinessGlossaryID
,	parent.BusinessGlossaryID_Parent
,	parent.BusinessGlossaryCode AS Path1
,	CONVERT(VARCHAR(100), NULL) AS Path2
,	CONVERT(VARCHAR(100), NULL) AS Path3
,	CONVERT(VARCHAR(100), NULL) as Path4
,	0 AS Path_Level

FROM 
	[DataManager_Local].[BG].[vw_BusinessGlossary] AS parent
WHERE 
	BusinessGlossaryID_Parent IS NULL

UNION ALL 

SELECT 
	child.BusinessGlossaryID
,	child.BusinessGlossaryID_Parent
,	Path1
,	CASE WHEN Path_Level + 1 = 1 THEN BusinessGlossaryCode ELSE Path2 END
,	CASE WHEN Path_Level + 1 = 2 THEN BusinessGlossaryCode ELSE Path3 END
,	CASE WHEN Path_Level + 1 = 3 THEN BusinessGlossaryCode ELSE Path4 END
,	Path_Level + 1
FROM 
	TreeCTE AS tree
INNER JOIN 
	[DataManager_Local].[BG].[vw_BusinessGlossary] AS child
	ON child.BusinessGlossaryID_Parent = tree.BusinessGlossaryID
) 
SELECT * FROM TreeCTE
