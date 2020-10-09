SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductCostHistorySAT](
	[ProductCostHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[StandardCost] [money] NOT NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO
