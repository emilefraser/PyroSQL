SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_ExecutionLogSteps](
	[ExecutionLogStepID] [int] NOT NULL,
	[ExecutionLogID] [int] NOT NULL,
	[ExecutionStepNo] [int] NULL,
	[StepDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Action] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NULL,
	[FinishDT] [datetime2](7) NULL,
	[DurationSeconds] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedRecordCount] [int] NULL
) ON [PRIMARY]

GO
