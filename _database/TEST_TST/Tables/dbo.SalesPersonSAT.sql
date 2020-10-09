SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesPersonSAT](
	[SalesPersonVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Bonus] [money] NOT NULL,
	[CommissionPct] [decimal](18, 0) NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesQuota] [money] NULL
) ON [PRIMARY]

GO
