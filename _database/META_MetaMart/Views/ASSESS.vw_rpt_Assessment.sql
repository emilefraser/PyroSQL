SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE VIEW [ASSESS].[vw_rpt_Assessment] AS (
SELECT
[AssessmentID],
[AssessmentName],
[CustomerID]
FROM [ASSESS].[Assessment]
)
GO
