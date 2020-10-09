SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[LinkReportingHierarchyItemToBKCombination](
	[LinkID] [int] IDENTITY(1,1) NOT NULL,
	[ReportingHierarchyItemID] [int] NOT NULL,
	[SortOrder] [int] NULL
) ON [PRIMARY]

GO
