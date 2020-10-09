SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesPersonQuotaHistoryHUB](
	[SalesPersonQuotaHistoryVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SalesPersonID] [bigint] NOT NULL,
	[QuotaDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
