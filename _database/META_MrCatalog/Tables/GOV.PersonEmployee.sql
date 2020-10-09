SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [GOV].[PersonEmployee](
	[PersonEmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[EmployeeNo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[PersonEmployeeCode] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
