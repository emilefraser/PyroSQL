SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportingHierarchyUserAccessBKLink](
	[DomainAccount] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsDefaultHierarchyItem] [int] NOT NULL,
	[ReportingHierarchyTypeCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyTypeName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportItemSortOrder] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[BusinessKey] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportBKSortOrder] [int] NOT NULL
) ON [PRIMARY]

GO
