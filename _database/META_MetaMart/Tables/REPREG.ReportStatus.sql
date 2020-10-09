SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportStatus](
	[ReportStatusID] [int] IDENTITY(1,1) NOT NULL,
	[ReportID] [int] NULL,
	[ReportStatusTypeID] [int] NULL,
	[ErrorParagraph] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
