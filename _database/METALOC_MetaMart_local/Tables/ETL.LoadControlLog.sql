SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ETL].[LoadControlLog](
	[LoadControlID] [int] NOT NULL,
	[QueuedForProcessingDT] [datetime2](7) NOT NULL,
	[ProcessingStartDT] [datetime2](7) NULL,
	[ProcessingFinishedDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewRowCount] [int] NULL,
	[UpdatedRowCount] [int] NULL,
	[NewRowBytes] [int] NULL,
	[UpdatedRowBytes] [int] NULL,
	[IsReload] [bit] NULL,
	[IsError] [bit] NULL,
	[ErrorMessage] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DeletedRowCount] [int] NULL
) ON [PRIMARY]

GO
