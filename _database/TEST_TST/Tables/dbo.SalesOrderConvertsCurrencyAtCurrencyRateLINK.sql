SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SalesOrderConvertsCurrencyAtCurrencyRateLINK](
	[SalesOrderConvertsCurrencyAtCurrencyRate] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[CurrencyRateVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
