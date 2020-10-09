SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportStatusType](
	[ReportStatusTypeID] [int] NOT NULL,
	[ReportStatusTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DefaultErrorParagraph] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportStatusIndicator] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
