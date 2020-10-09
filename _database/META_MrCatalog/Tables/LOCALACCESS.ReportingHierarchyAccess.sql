SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [LOCALACCESS].[ReportingHierarchyAccess](
	[HashKey] [varchar](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyTypeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingHierarchyTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingHierarchyItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingHierarchyItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentReportingHierarchyItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ParentReportingHierarchyItemName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BusinessKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataCatalogFieldID] [int] NULL,
	[FieldName] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsDefaultHierarchyItem] [bit] NULL,
	[DomainAccount] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L1] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L2] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L3] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L4] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L5] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L6] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L7] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L8] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L9] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[L10] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
