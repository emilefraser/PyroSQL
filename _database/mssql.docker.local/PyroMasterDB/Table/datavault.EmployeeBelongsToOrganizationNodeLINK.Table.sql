SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK](
	[EmployeeBelongsToOrganizationNodeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[OrganizationNodeDepartmentVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeBelongsToOrganizationNodeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[OrganizationNodeDepartmentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[OrganizationNodeDepartmentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[OrganizationNodeDepartmentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Emplo__7128A7F2]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Emplo__7A52EAD0]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Emplo__7CBA562F]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Organ__721CCC2B]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([OrganizationNodeDepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Organ__7B470F09]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([OrganizationNodeDepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeB__Organ__7DAE7A68]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeBelongsToOrganizationNodeLINK]'))
ALTER TABLE [datavault].[EmployeeBelongsToOrganizationNodeLINK]  WITH CHECK ADD FOREIGN KEY([OrganizationNodeDepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
