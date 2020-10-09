SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[EmployeePayHistorySAT](
	[EmployeePayHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[PayFrequency] [tinyint] NOT NULL,
	[Rate] [money] NOT NULL
) ON [PRIMARY]

GO
