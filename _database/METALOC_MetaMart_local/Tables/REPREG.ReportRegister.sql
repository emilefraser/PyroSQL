SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportRegister](
	[ReportID] [uniqueidentifier] NOT NULL,
	[ReportName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportDescription] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportTypeDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportPackTitle] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportPackDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ErrorParagraph] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportStatusIndicator] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportStatusTypeName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportTechnologyName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsReportPackCapable] [bit] NULL,
	[ReportElementName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportElementDescription] [varchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
