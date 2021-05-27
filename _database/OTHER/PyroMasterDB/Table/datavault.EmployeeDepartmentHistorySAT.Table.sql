SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeDepartmentHistorySAT](
	[EmployeeDepartmentHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeDepartmentHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__017F0B4C]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistorySAT]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeeDepartmentHistoryVID])
REFERENCES [datavault].[EmployeeDepartmentHistoryLINK] ([EmployeeDepartmentHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__75ED5D0F]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistorySAT]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeeDepartmentHistoryVID])
REFERENCES [datavault].[EmployeeDepartmentHistoryLINK] ([EmployeeDepartmentHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeD__Emplo__7F179FED]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeDepartmentHistorySAT]'))
ALTER TABLE [datavault].[EmployeeDepartmentHistorySAT]  WITH CHECK ADD FOREIGN KEY([EmployeeDepartmentHistoryVID])
REFERENCES [datavault].[EmployeeDepartmentHistoryLINK] ([EmployeeDepartmentHistoryVID])
GO
