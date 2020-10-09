SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ETLBatchControl_Local](
	[LocalBatchID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityID] [int] NULL,
	[BatchDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastTransactionDate] [datetime] NULL,
	[ExecutionStartDate] [datetime] NULL,
	[ExecutionEndDate] [datetime] NULL,
	[ExecutionStatus] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PackageName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransferRowCount] [int] NULL
) ON [PRIMARY]

GO
