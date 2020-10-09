SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REPREG].[LinkReportGlossaryToReportPack](
	[LinkReportGlossaryToReportPack] [uniqueidentifier] NOT NULL,
	[ReportPackID] [uniqueidentifier] NOT NULL,
	[ReportGlossaryID] [uniqueidentifier] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL
) ON [PRIMARY]

GO
