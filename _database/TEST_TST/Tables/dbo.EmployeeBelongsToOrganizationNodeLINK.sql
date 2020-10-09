SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeeBelongsToOrganizationNodeLINK](
	[EmployeeBelongsToOrganizationNodeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[OrganizationNodeDepartmentVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
