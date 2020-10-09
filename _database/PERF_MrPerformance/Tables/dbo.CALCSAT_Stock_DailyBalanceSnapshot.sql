SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CALCSAT_Stock_DailyBalanceSnapshot](
	[HK_Stock] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LoadDT] [datetime2](7) NOT NULL,
	[DateKey] [datetime] NOT NULL,
	[QtyOnHand] [decimal](29, 4) NOT NULL,
	[AveCostPerUnit] [decimal](29, 4) NOT NULL,
	[TotalCost] [decimal](29, 2) NOT NULL
) ON [PRIMARY]

GO
