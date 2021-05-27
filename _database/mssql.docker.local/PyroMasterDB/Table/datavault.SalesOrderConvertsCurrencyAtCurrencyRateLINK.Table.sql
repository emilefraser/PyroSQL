SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK](
	[SalesOrderConvertsCurrencyAtCurrencyRate] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesOrderVID] [bigint] NOT NULL,
	[CurrencyRateVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesOrderConvertsCurrencyAtCurrencyRate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CurrencyRateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CurrencyRateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesOrderVID] ASC,
	[CurrencyRateVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Curre__39A368DE]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Curre__42CDABBC]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Curre__4535171B]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__3A978D17]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__43C1CFF5]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesOrde__Sales__46293B54]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]'))
ALTER TABLE [datavault].[SalesOrderConvertsCurrencyAtCurrencyRateLINK]  WITH CHECK ADD FOREIGN KEY([SalesOrderVID])
REFERENCES [datavault].[SalesOrderHUB] ([SalesOrderVID])
GO
