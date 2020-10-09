SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportRole](
	[ReportRoleID] [int] IDENTITY(1,1) NOT NULL,
	[ReportRoleName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ReportRoleDescription] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ReportRegisterID] [int] NULL
) ON [PRIMARY]

GO
