SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadControlLog](
	[LoadControlLogID] [int] NOT NULL,
	[LoadControlID] [int] NOT NULL,
	[QueuedForProcessingDT] [datetime2](7) NOT NULL,
	[ProcessingStartDT] [datetime2](7) NULL,
	[ProcessingFinishedDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewRowCount] [bigint] NULL,
	[UpdatedRowCount] [bigint] NULL,
	[DeletedRowCount] [bigint] NULL,
	[NewRowBytes] [bigint] NULL,
	[UpdatedRowBytes] [bigint] NULL,
	[IsReload] [bit] NOT NULL,
	[IsError] [bit] NOT NULL,
	[ErrorMessage] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
