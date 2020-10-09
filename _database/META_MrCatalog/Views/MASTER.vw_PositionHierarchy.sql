SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON



CREATE view [MASTER].[vw_PositionHierarchy] 
AS
/*
   WITH cte_Position 
   AS
		(
			SELECT	c.CompanyID
					, c.CompanyCode
				    , pos.EmployeePositionCode as PosCode
					, CONVERT(VARCHAR(50), NULL) as ReportsToPosCode
					, pos.EmployeePositionID
					, CONVERT(INT, NULL) AS ReportsToPositionID
					, 1 AS OrgLevel
			FROM	[SOURCELINK].EmployeePosition pos
				    INNER JOIN [MASTER].[CompanyLeadPosition] leadpos ON
						leadpos.CompanyID = pos.CompanyID AND
						leadpos.LeadEmployeePositionID = pos.EmployeePositionID
					INNER JOIN [CONFIG].Company c ON
						c.CompanyID = pos.CompanyID


			UNION ALL

			SELECT	c2.CompanyID
					, c2.CompanyCode
				    , pos2.EmployeePositionCode as PosCode
					, parentpos.EmployeePositionCode as ReportsToPosCode
					, pos2.EmployeePositionID
					, pos2.ReportsToPositionID
					, poscte.OrgLevel + 1 AS OrgLevel
			FROM	[SOURCELINK].EmployeePosition pos2
					JOIN cte_Position poscte ON poscte.EmployeePositionID = pos2.ReportsToPositionID
					INNER JOIN [SOURCELINK].EmployeePosition parentpos ON
						parentpos.EmployeePositionID = pos2.ReportsToPositionID
					INNER JOIN CONFIG.Company c2 ON
						c2.CompanyID = pos2.CompanyID

   )
	SELECT	cte_Position.CompanyID,
			cte_Position.CompanyCode,
			cte_Position.PosCode,
			cte_Position.ReportsToPosCode,
			cte_Position.EmployeePositionID,
			cte_Position.ReportsToPositionID,
			cte_Position.OrgLevel
	FROM	cte_Position

GO
*/

   WITH cte_Position  ----****************WS: Works
   AS
		(
			SELECT	c.CompanyID            
					, c.CompanyCode
				    , ORGpos.PositionCode as PosCode
					, CONVERT(VARCHAR(50), NULL) as ReportsToPosCode
					, ORGpos.OrgChartPositionID
					, CONVERT(INT, NULL) AS ReportsToOrgChartPositionID
					, 1 AS OrgLevel
			FROM	[GOV].OrgChartPosition ORGpos                        --ws: CODE WAS ALTERed to only return the records with 1 for is top node
					INNER JOIN [CONFIG].Company c ON c.CompanyID = ORGpos.CompanyID
			WHERE ORGpos.IsTopNode = 1

						


			UNION ALL

			SELECT	c2.CompanyID
					, c2.CompanyCode
				    , ORGpos2.PositionCode as PosCode
					, parentORGpos.PositionCode as ReportsToPosCode
					, ORGpos2.OrgChartPositionID
					, ORGpos2.ReportsToOrgChartPositionID
					, poscte.OrgLevel + 1 AS OrgLevel
			FROM	[GOV].OrgChartPosition ORGpos2
					JOIN cte_Position poscte ON poscte.OrgChartPositionID = ORGpos2.ReportsToOrgChartPositionID
					INNER JOIN [GOV].OrgChartPosition parentORGpos ON
						parentORGpos.OrgChartPositionID = ORGpos2.ReportsToOrgChartPositionID
					INNER JOIN CONFIG.Company c2 ON
						c2.CompanyID = ORGpos2.CompanyID

   )
	SELECT	cte_Position.CompanyID,
			cte_Position.CompanyCode,
			cte_Position.PosCode,
			cte_Position.ReportsToPosCode,
			cte_Position.OrgChartPositionID,
			cte_Position.ReportsToOrgChartPositionID,
			cte_Position.OrgLevel
	FROM	cte_Position


GO
