SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ExecutionLogSteps](
	[ExecutionLogStepID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionLogID] [int] NOT NULL,
	[ExecutionStepNo] [int] NULL,
	[StepDescription] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedDatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedSchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedDataEntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Action] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NULL,
	[FinishDT] [datetime2](7) NULL,
	[DurationSeconds] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AffectedRecordCount] [int] NULL
) ON [PRIMARY]

GO
