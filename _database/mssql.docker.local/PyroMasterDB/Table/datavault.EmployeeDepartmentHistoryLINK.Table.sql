SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeDepartmentHistoryLINK](
	[EmployeeDepartmentHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[DepartmentVID] [bigint] NOT NULL,
	[ShiftVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeDepartmentHistoryVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[StartDate] ASC,
	[DepartmentVID] ASC,
	[ShiftVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[StartDate] ASC,
	[DepartmentVID] ASC,
	[ShiftVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeeVID] ASC,
	[StartDate] ASC,
	[DepartmentVID] ASC,
	[ShiftVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Depar__7310F064]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Depar__7C3B3342]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Depar__7EA29EA1]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([DepartmentVID])
REFERENCES [datavault].[DepartmentHUB] ([DepartmentVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__7405149D]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__7D2F577B]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__7F96C2DA]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Shift__008AE713]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Shift__74F938D6]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Shift__7E237BB4]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistoryLINK]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistoryLINK]  WITH CHECK ADD FOREIGN KEY([ShiftVID])
REFERENCES [datavault].[ShiftHUB] ([ShiftVID])
GO
