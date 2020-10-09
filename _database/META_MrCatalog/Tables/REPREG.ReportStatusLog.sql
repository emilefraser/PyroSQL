SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportStatusLog](
	[ReportStatusID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NULL,
	[ReportStatusTypeID] [int] NULL,
	[ErrorParagraph] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LogDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
