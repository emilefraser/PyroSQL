SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[ExecutionLogpoc](
	[ExecutionLogID] [int] NOT NULL,
	[LoadConfigID] [int] NULL,
	[DatabaseName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SchemaName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataEntityName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NULL,
	[FinishDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsReload] [bit] NULL,
	[Result] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorMessage] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsError] [int] NULL,
	[IsDataIntegrityError] [bit] NULL,
	[SourceRowCount] [int] NULL,
	[SourceTableSizeBytes] [int] NULL,
	[InitialTargetRowCount] [int] NULL,
	[InitialTargetTableSizeBytes] [int] NULL,
	[RowsTransferred] [int] NULL,
	[DeletedRowCount] [int] NULL,
	[UpdatedRowCount] [int] NULL,
	[UpdatedRowBytes] [int] NULL,
	[TargetRowCount] [int] NULL,
	[TargetTableSizeBytes] [int] NULL,
	[NewRowCount] [int] NULL,
	[NewRowsBytes] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
