SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [ASSESS].[vw_pres_Assessment] AS (
SELECT
[AssessmentID] AS [Assessment ID],
[AssessmentName] AS [Assessment Name],
[CustomerID] AS [Customer ID]
FROM [ASSESS].[vw_rpt_Assessment]
)
GO
