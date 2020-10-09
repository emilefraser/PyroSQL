SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[ReportingHierarchyItem](
	[ReportingHierarchyItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyTypeID] [int] NULL,
	[ParentItemID] [int] NULL,
	[CompanyID] [int] NULL,
	[ReportingHierarchySortOrder] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
