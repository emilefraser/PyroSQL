SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	[EndDT] [datetime2](7) NULL,
 CONSTRAINT [PK_JobExecutionMonitor] PRIMARY KEY CLUSTERED 
(
	[JobRunDependencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ETL].[JobExecutionMonitor] ADD  DEFAULT ((0)) FOR [ExecutionStatus]
GO
ALTER TABLE [ETL].[JobExecutionMonitor] ADD  DEFAULT ((0)) FOR [IsCurrentlyRunning]
GO
