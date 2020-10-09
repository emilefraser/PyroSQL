SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[ReportGlossary](
	[ReportGlossaryID] [uniqueidentifier] NOT NULL,
	[ReportGlossaryCode] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportGlossaryName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportGlossaryDescription] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
