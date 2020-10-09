SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportTechnology](
	[ReportTechnologyID] [int] IDENTITY(1,1) NOT NULL,
	[ReportTechnologyName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsReportPackCapable] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
