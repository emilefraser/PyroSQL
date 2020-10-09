SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[ReportingHierarchyType](
	[ReportingHierarchyTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ReportingHierarchyTypeName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyDescription] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HierarchyLevelsLimit] [smallint] NOT NULL,
	[IsUniqueBKMapping] [bit] NULL,
	[ReportingHierarchyTypeCode] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[DataDomainID] [int] NULL,
	[IsMultipleTopParentAllowed] [bit] NULL
) ON [PRIMARY]

GO
