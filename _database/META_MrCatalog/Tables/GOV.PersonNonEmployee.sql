SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[PersonNonEmployee](
	[PersonNonEmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[SupplierCompany] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JobTitle] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Code] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportsToOrgChartPositionID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
