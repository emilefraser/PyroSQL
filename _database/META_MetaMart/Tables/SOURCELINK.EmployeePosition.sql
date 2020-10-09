SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SOURCELINK].[EmployeePosition](
	[EmployeePositionID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeePositionCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EmployeePositionDescription] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportsToPositionID] [int] NULL,
	[EmployeeID] [int] NULL,
	[CompanyID] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
