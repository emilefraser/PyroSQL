SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ExecutionLog](
	[ExecutionLogID] [int] IDENTITY(1,1) NOT NULL,
	[LoadConfigID] [int] NULL,
	[DatabaseName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityName] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsLastRunOfConfigID] [bit] NULL,
	[QueuedForProcessingDT] [datetime2](7) NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[FinishDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsReload] [bit] NULL,
	[Result] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsError] [bit] NULL,
	[IsDataIntegrityError] [bit] NULL,
	[ErrorNumber] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorLine] [int] NULL,
	[ErrorMessage] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SourceRowCount] [bigint] NULL,
	[SourceTableSizeBytes] [bigint] NULL,
	[SourceRowCountToCopy] [bigint] NULL,
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
