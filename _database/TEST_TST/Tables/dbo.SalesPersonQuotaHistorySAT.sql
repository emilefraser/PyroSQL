SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesPersonQuotaHistorySAT](
	[SalesPersonQuotaHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[SalesQuota] [money] NOT NULL
) ON [PRIMARY]

GO
