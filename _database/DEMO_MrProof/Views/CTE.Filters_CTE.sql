SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW CTE.Filters_CTE AS
WITH cte AS
(
  SELECT 
    [ICFilterID], 
    [ParentID],
    [FilterDesc],
    [Active],
    CAST(0 AS varbinary(max)) AS Level
  FROM [CTE].[FiltersCTE_Demo]
  WHERE [ParentID] = 0
  UNION ALL
  SELECT 
    i.[ICFilterID], 
    i.[ParentID],
    i.[FilterDesc],
    i.[Active],  
    Level + CAST(i.[ICFilterID] AS varbinary(max)) AS Level
  FROM [CTE].[FiltersCTE_Demo] i
  INNER JOIN cte c
    ON c.[ICFilterID] = i.[ParentID]
)

SELECT 
  [ICFilterID], 
  [ParentID],
  [FilterDesc],
  [Active]
FROM cte

GO
