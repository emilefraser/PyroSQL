SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeePayHistoryHUB](
	[EmployeePayHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [bigint] NOT NULL,
	[RateChangeDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
