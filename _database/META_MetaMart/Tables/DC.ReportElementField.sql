SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [DC].[ReportElementField](
	[ReportElementFieldID] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportElementID] [int] NOT NULL,
	[FieldID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
