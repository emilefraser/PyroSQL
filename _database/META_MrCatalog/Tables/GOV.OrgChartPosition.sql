SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[OrgChartPosition](
	[OrgChartPositionID] [int] IDENTITY(1,1) NOT NULL,
	[PositionCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PositionDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportsToOrgChartPositionID] [int] NULL,
	[IsTopNode] [bit] NOT NULL,
	[CompanyID] [int] NULL,
	[PersonEmployeeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]

GO
