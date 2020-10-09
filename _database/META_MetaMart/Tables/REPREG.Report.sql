SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[Report](
	[ReportID] [int] IDENTITY(1,1) NOT NULL,
	[ReportName] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Description] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[KeyObservations] [varchar](5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Location] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportOwnerID] [int] NULL,
	[ReportType] [int] NULL,
	[ReportPackID] [int] NULL,
	[ReportTechnologyID] [int] NULL,
	[IsDynamicReport] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
