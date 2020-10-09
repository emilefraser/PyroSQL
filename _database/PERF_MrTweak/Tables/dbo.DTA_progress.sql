SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[DTA_progress](
	[ProgressEventID] [int] IDENTITY(1,1) NOT NULL,
	[SessionID] [int] NULL,
	[TuningStage] [tinyint] NOT NULL,
	[WorkloadConsumption] [tinyint] NOT NULL,
	[EstImprovement] [int] NOT NULL,
	[ProgressEventTime] [datetime] NOT NULL,
	[ConsumingWorkLoadMessage] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PerformingAnalysisMessage] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GeneratingReportsMessage] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
