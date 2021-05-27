SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[EmployeeSAT](
	[EmployeeVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CurrentFlag] [bit] NULL,
	[SalariedFlag] [bit] NULL,
	[BirthDate] [datetime] NOT NULL,
	[Gender] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[HireDate] [datetime] NOT NULL,
	[JobTitle] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoginID] [varchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MaritalStatus] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NationalIDNumber] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SickLeaveHours] [int] NOT NULL,
	[VacationHours] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeS__Emplo__04D07943]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeS__Emplo__0737E4A2]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__EmployeeS__Emplo__7BA63665]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Gende__0055DCE9]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([Gender]='F' OR [Gender]='M' OR [Gender]='f' OR [Gender]='m'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Gende__7894BF90]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([Gender]='F' OR [Gender]='M' OR [Gender]='f' OR [Gender]='m'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Gende__7DEE718A]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([Gender]='F' OR [Gender]='M' OR [Gender]='f' OR [Gender]='m'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Marit__014A0122]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([MaritalStatus]='M' OR [MaritalStatus]='S'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Marit__7988E3C9]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([MaritalStatus]='M' OR [MaritalStatus]='S'))
GO
IF NOT EXISTS (SELECT * FROM sys.check_constraints WHERE object_id = OBJECT_ID(N'[datavault].[CK__EmployeeS__Marit__7EE295C3]') AND parent_object_id = OBJECT_ID(N'[datavault].[EmployeeSAT]'))
ALTER TABLE [datavault].[EmployeeSAT]  WITH CHECK ADD CHECK  (([MaritalStatus]='M' OR [MaritalStatus]='S'))
GO
