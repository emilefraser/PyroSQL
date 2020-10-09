SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [SOURCELINK].[Employee](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FirstName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Surname] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[Department] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportingHierarchyItemID] [int] NULL
) ON [PRIMARY]

GO
