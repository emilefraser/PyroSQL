SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_ExecutionLog](
	[ExecutionLogID] [int] IDENTITY(1,1) NOT NULL,
	[LoadConfigID] [int] NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QueuedForProcessingDT] [datetime2](7) NULL,
	[StartDT] [datetime2](7) NULL,
	[FinishDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsReload] [bit] NULL,
	[Result] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorMessage] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsError] [int] NULL,
	[IsDataIntegrityError] [bit] NULL,
	[SourceRowCount] [bigint] NULL,
	[SourceTableSizeBytes] [bigint] NULL,
	[SourceRowCountToCopy] [bigint] NULL,
	[SourceRowCountToCopyUpdate] [bigint] NULL,
	[InitialTargetRowCount] [bigint] NULL,
	[InitialTargetTableSizeBytes] [bigint] NULL,
	[RowsTransferred] [bigint] NULL,
	[DeletedRowCount] [bigint] NULL,
	[UpdatedRowCount] [bigint] NULL,
	[UpdatedRowBytes] [bigint] NULL,
	[TargetRowCount] [bigint] NULL,
	[TargetTableSizeBytes] [bigint] NULL,
	[NewRowCount] [bigint] NULL,
	[NewRowsBytes] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
