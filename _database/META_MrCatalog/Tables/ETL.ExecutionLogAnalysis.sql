SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ExecutionLogAnalysis](
	[ExecutionLogID] [int] NOT NULL,
	[DurationSeconds] [int] NULL,
	[QueueSeconds] [int] NULL,
	[TotalExecutionTime] [int] NULL,
	[IsDataIntegrityError] [bit] NULL
) ON [PRIMARY]

GO
