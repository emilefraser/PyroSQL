SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportingHierarchyAccess](
	[HashKey] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyTypeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingHierarchyTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BusinessKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LinkID] [int] NULL,
	[DataCatalogFieldID] [int] NULL,
	[FieldName] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsDefaultHierarchyItem] [bit] NULL,
	[DomainAccount] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
