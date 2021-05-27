SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK](
	[EmployeePayHistoryInvolvesEmployeeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeePayHistoryVID] [bigint] NOT NULL,
	[EmployeeVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeePayHistoryInvolvesEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeePayHistoryVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeePayHistoryVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[EmployeePayHistoryVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__01F40C98]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__02E830D1]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__045B77F7]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__054F9C30]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__78C9C9BA]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeePayHistoryVID])
REFERENCES [datavault].[EmployeePayHistoryHUB] ([EmployeePayHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeP__Emplo__79BDEDF3]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeePayHistoryInvolvesEmployeeLINK]'))
ALTER TABLE [datavault].[EmployeePayHistoryInvolvesEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
