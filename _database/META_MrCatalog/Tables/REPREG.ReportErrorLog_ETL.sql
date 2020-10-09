SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportErrorLog_ETL](
	[ReportErrorLog_ETL_ID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NOT NULL,
	[ETLStepID] [int] NULL,
	[ErrorTypeID] [int] NULL,
	[ErrorDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
