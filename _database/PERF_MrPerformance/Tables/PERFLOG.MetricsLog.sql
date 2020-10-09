SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [PERFLOG].[MetricsLog](
	[LogID] [int] NOT NULL,
	[Spid] [int] NULL,
	[EstimatedCost] [float] NOT NULL,
	[Duration] [int] NULL,
	[CPU] [int] NULL,
	[Reads] [int] NULL,
	[Writes] [int] NULL,
	[EstimatedIOCost] [float] NULL,
	[EstimatedRows] [int] NULL,
	[ActualRows] [int] NULL
) ON [PRIMARY]

GO
