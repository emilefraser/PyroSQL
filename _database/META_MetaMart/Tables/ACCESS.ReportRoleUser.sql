SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [ACCESS].[ReportRoleUser](
	[ReportRoleUserID] [int] IDENTITY(1,1) NOT NULL,
	[PersonAccessControlListID] [int] NOT NULL,
	[ReportRoleID] [int] NOT NULL
) ON [PRIMARY]

GO
