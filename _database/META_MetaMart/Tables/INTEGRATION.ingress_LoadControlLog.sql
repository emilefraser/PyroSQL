SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [INTEGRATION].[ingress_LoadControlLog](
	[LoadControlLogID] [int] IDENTITY(1,1) NOT NULL,
	[LoadControlID] [int] NOT NULL,
	[QueuedForProcessingDT] [datetime2](7) NOT NULL,
	[ProcessingStartDT] [datetime2](7) NULL,
	[ProcessingFinishedDT] [datetime2](7) NULL,
	[LastProcessingKeyValue] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NewRowCount] [int] NULL,
	[UpdatedRowCount] [int] NULL,
	[DeletedRowCount] [int] NULL,
	[NewRowBytes] [int] NULL,
	[UpdatedRowBytes] [int] NULL,
	[IsReload] [bit] NOT NULL,
	[IsError] [bit] NOT NULL,
	[ErrorMessage] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
