SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[RoadmapProject](
	[RoadmapProjectID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProjectDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BusinessArea] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BusinessSubArea] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProjectStartDate] [date] NULL,
	[EstimatedDurationDays] [int] NOT NULL,
	[BusinessImpactScore] [decimal](4, 2) NOT NULL,
	[FeasibilityScore] [decimal](4, 2) NOT NULL,
	[CompletionPercentage] [decimal](4, 2) NULL,
	[IsFollowPriorityQueue] [bit] NULL
) ON [PRIMARY]

GO
