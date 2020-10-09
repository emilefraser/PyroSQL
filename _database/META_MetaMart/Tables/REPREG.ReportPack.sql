SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportPack](
	[ReportPackID] [int] IDENTITY(1,1) NOT NULL,
	[ReportPackTitle] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportPackDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportTechnologyID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[ModifedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
