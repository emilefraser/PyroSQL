SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


CREATE VIEW [GOV].[vw_mat_RoadmapProjectList] AS
SELECT [ProjectName] AS [Project]
	  ,[ProjectDescription] AS [Project Description]
      ,[BusinessArea] AS [Business Area]
      ,[BusinessSubArea] AS [Business Sub Area]
      ,[EstimatedDurationDays] AS [Estimated Duration Days]
	  ,[ProjectStartDate] AS [Project Start Date]
      ,[BusinessImpactScore] AS [Business Impact Score]
      ,[FeasibilityScore] AS [Feasibility Score]
	  ,[PrioritisationIndex] AS [Prioritisation Index]
	  ,[ProjectSize] AS [Project Size]
	  ,[CompletionPercentage] AS [Completion %]
	  ,CASE WHEN [IsFollowPriorityQueue] = 1 THEN 'Yes' ELSE 'No' END AS [Follows Priority Queue]
  FROM GOV.vw_rpt_RoadmapProjectList





GO
