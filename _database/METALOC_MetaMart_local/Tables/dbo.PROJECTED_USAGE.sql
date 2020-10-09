SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[PROJECTED_USAGE](
	[ProjectedUsageId] [int] NULL,
	[EqpProjId] [int] NULL,
	[QUOMId] [int] NULL,
	[StartUsage] [real] NULL,
	[EndUsage] [real] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[UsageFromDateFactor] [real] NULL,
	[DateFromUsageFactor] [real] NULL,
	[UsageStepId] [int] NULL,
	[DateOrder] [int] NULL
) ON [PRIMARY]

GO
