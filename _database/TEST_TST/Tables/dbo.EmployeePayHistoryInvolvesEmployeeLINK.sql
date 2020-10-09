SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeePayHistoryInvolvesEmployeeLINK](
	[EmployeePayHistoryInvolvesEmployeeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeePayHistoryVID] [bigint] NOT NULL,
	[EmployeeVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
