SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportUser](
	[ReportUserID] [int] IDENTITY(1,1) NOT NULL,
	[DomainAccount] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IsActive] [bit] NOT NULL,
	[EmployeeID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL
) ON [PRIMARY]

GO
