SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[JobExecutionMonitor](
	[JobExecutionMonitorID] [int] IDENTITY(1,1) NOT NULL,
	[JobBatchID] [int] NOT NULL,
	[JobGroupID] [int] NOT NULL,
	[JobID] [int] NOT NULL,
	[RunOrder] [int] NOT NULL,
	[JobRunDependencyID] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExecutionStatus] [bit] NULL,
	[IsCurrentlyRunning] [bit] NULL,
	[StartDT] [datetime2](7) NULL,
	[EndDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
