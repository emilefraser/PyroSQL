SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ETLBatchControl](
	[BatchID] [int] NOT NULL,
	[ETLStepID] [int] NULL,
	[DataEntityID] [int] NULL,
	[LastTransactionDate] [datetime] NULL,
	[ExecutionStartDate] [datetime] NULL,
	[ExecutionEndDate] [datetime] NULL,
	[ExecutionStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PackageName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransferRowCount] [int] NULL
) ON [PRIMARY]

GO
