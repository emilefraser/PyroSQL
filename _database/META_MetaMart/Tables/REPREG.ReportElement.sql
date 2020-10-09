SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportElement](
	[ReportElementID] [int] IDENTITY(1,1) NOT NULL,
	[ReportElementName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportElementDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
