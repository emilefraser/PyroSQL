SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_ExecutionLogSteps](
	[ExecutionLogStepID] [int] NOT NULL,
	[ExecutionLogID] [int] NOT NULL,
	[ExecutionStepNo] [int] NULL,
	[StepDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AffectedDatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AffectedSchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AffectedDataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Action] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[FinishDT] [datetime2](7) NOT NULL,
	[DurationSeconds] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AffectedRecordCount] [int] NOT NULL
) ON [PRIMARY]

GO
