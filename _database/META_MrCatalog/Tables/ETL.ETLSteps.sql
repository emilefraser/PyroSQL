SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ETLSteps](
	[ETLStepID] [int] IDENTITY(1,1) NOT NULL,
	[ETLID] [int] NULL,
	[StepDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StepSchedule] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StepExecutionOrder] [int] NOT NULL,
	[CurrentStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastRunDate] [datetime] NULL,
	[LastRunStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
