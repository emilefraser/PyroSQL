SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE VIEW [GOV].[vw_rpt_RoadmapProjectList] AS
	SELECT [RoadmapProjectID]
		  ,[ProjectName]
		  ,[ProjectDescription]
		  ,[BusinessArea]
		  ,[BusinessSubArea]
		  ,[ProjectStartDate] = 
			 CASE WHEN [ProjectStartDate] IS NULL
		       THEN DATEADD(d,
							SUM(CASE WHEN [IsFollowPriorityQueue] = 1 THEN [EstimatedDurationDays] ELSE 0 END) OVER(ORDER BY CONVERT(DECIMAL(4, 2), SQRT([BusinessImpactScore] * [FeasibilityScore])) DESC, [IsFollowPriorityQueue] DESC ROWS UNBOUNDED PRECEDING) - [EstimatedDurationDays],
							startpriorityqueue.RoadmapStartDate)
			   ELSE proj.ProjectStartDate
		     END
		  ,[EstimatedDurationDays]
		  ,[BusinessImpactScore]
		  ,[FeasibilityScore]
		  ,ISNULL([CompletionPercentage], 0) AS [CompletionPercentage]
		  ,CONVERT(DECIMAL(4, 2), SQRT([BusinessImpactScore] * [FeasibilityScore])) AS [PrioritisationIndex]
		  ,CONVERT(DECIMAL(4, 2), CONVERT(DECIMAL(18, 0), [EstimatedDurationDays]) / largestproj.LargestProjectSize * 10.0) AS [ProjectSize]
		  ,[IsFollowPriorityQueue]
	  FROM [GOV].[RoadmapProject] proj
		   CROSS JOIN (SELECT CONVERT(DECIMAL(18, 0), MAX([EstimatedDurationDays])) AS LargestProjectSize FROM [GOV].[RoadmapProject]) largestproj
		   CROSS JOIN (SELECT TOP 1 ProjectStartDate AS RoadmapStartDate FROM [GOV].[RoadmapProject] WHERE [IsFollowPriorityQueue] = 1 AND ProjectStartDate IS NOT NULL) startpriorityqueue
--ORDER BY PrioritisationIndex DESC

GO
