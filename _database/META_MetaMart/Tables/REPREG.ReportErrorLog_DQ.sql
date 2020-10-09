SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportErrorLog_DQ](
	[ReportErrorLogID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NOT NULL,
	[DataCatalogFieldID] [int] NULL,
	[BusinessKeyID] [int] NULL,
	[ErrorTypeID] [int] NULL,
	[ErrorDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TransactionPeriod] [varchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
