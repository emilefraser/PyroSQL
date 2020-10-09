SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeeDepartmentHistoryLINK](
	[EmployeeDepartmentHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[DepartmentVID] [bigint] NOT NULL,
	[ShiftVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
