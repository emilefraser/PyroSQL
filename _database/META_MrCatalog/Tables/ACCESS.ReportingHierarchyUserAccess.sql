SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportingHierarchyUserAccess](
	[ReportingHierarchyUserAccessID] [int] IDENTITY(1,1) NOT NULL,
	[ReportingHierarchyItemID] [int] NOT NULL,
	[PersonAccessControlListID] [int] NOT NULL,
	[IsDefaultHierarchyItem] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
