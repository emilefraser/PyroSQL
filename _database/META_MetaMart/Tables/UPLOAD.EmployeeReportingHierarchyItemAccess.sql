SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [UPLOAD].[EmployeeReportingHierarchyItemAccess](
	[EmployeeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyItemCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportingHierarchyTypeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
