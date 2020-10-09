SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE view [MASTER].[vw_PositionHierarchyWithLevels]
AS
SELECT 'View is to be refactored with changes in the reporting hierarchy structures.' AS TODO
 --  WITH cte
 --  AS
	--	(
	--		SELECT	pos.CompanyID
	--				, pos.CompanyCode
	--			    , pos.PosCode
	--				, CONVERT(VARCHAR(50), NULL) AS LevelPosCode
	--				, pos.ReportsToPosCode
	--				, pos.EmployeePositionID
	--				, pos.ReportsToPositionID
	--				, pos.OrgLevel
	--				--, CASE WHEN NULL AS L1
	--		FROM	[MASTER].[vw_PositionHierarchy] pos

	--		UNION ALL

	--		SELECT	pos2.CompanyID
	--				, pos2.CompanyCode
	--			    , poscte.PosCode
	--				, pos2.PosCode AS LevelPosCode
	--				, pos2.ReportsToPosCode
	--				, pos2.EmployeePositionID
	--				, pos2.ReportsToPositionID
	--				, pos2.OrgLevel
	--		FROM	[MASTER].[vw_PositionHierarchy] pos2
	--				JOIN cte poscte ON poscte.ReportsToPositionID = pos2.EmployeePositionID

 --  )
	--SELECT CompanyID,
	--	   CompanyCode,
	--	   PosCode,
	--	   MAX(OrgLevel) AS OrgLevel,
	--	   MAX(L1) AS L1,
	--	   MAX(L2) AS L2,
	--	   MAX(L3) AS L3,
	--	   MAX(L4) AS L4,
	--	   MAX(L5) AS L5,
	--	   MAX(L6) AS L6,
	--	   MAX(L7) AS L7,
	--	   MAX(L8) AS L8,
	--	   MAX(L9) AS L9,
	--	   MAX(L10) AS L10
	--  FROM (
	--		SELECT	cte.CompanyID,
	--				cte.CompanyCode,
	--				cte.PosCode,
	--				cte.LevelPosCode,
	--				cte.ReportsToPosCode,
	--				cte.EmployeePositionID,
	--				cte.ReportsToPositionID,
	--				cte.OrgLevel,
	--				CASE WHEN cte.OrgLevel = 1 THEN LevelPosCode ELSE NULL END AS L1,
	--				CASE WHEN cte.OrgLevel = 2 THEN LevelPosCode ELSE NULL END AS L2,
	--				CASE WHEN cte.OrgLevel = 3 THEN LevelPosCode ELSE NULL END AS L3,
	--				CASE WHEN cte.OrgLevel = 4 THEN LevelPosCode ELSE NULL END AS L4,
	--				CASE WHEN cte.OrgLevel = 5 THEN LevelPosCode ELSE NULL END AS L5,
	--				CASE WHEN cte.OrgLevel = 6 THEN LevelPosCode ELSE NULL END AS L6,
	--				CASE WHEN cte.OrgLevel = 7 THEN LevelPosCode ELSE NULL END AS L7,
	--				CASE WHEN cte.OrgLevel = 8 THEN LevelPosCode ELSE NULL END AS L8,
	--				CASE WHEN cte.OrgLevel = 9 THEN LevelPosCode ELSE NULL END AS L9,
	--				CASE WHEN cte.OrgLevel = 10 THEN LevelPosCode ELSE NULL END AS L10

	--		  FROM	cte
	--		) a
	--GROUP BY CompanyID, CompanyCode, PosCode


GO
