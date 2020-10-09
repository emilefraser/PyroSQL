SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportElementStatus](
	[ReportElementStatusID] [int] NOT NULL,
	[ReportElementID] [int] NOT NULL,
	[ReportStatusTypeID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
