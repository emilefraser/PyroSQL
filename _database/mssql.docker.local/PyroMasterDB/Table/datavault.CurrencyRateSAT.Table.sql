SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CurrencyRateSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CurrencyRateSAT](
	[CurrencyRateVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AverageRate] [money] NOT NULL,
	[CurrencyRateDate] [datetime] NOT NULL,
	[EndOfDayRate] [money] NOT NULL,
	[FromCurrencyCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ToCurrencyCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CurrencyRateVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CurrencyR__Curre__60F24029]') AND parent_object_id = OBJECT_ID(N'[datavault].[CurrencyRateSAT]'))
ALTER TABLE [datavault].[CurrencyRateSAT]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CurrencyR__Curre__6A1C8307]') AND parent_object_id = OBJECT_ID(N'[datavault].[CurrencyRateSAT]'))
ALTER TABLE [datavault].[CurrencyRateSAT]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CurrencyR__Curre__6C83EE66]') AND parent_object_id = OBJECT_ID(N'[datavault].[CurrencyRateSAT]'))
ALTER TABLE [datavault].[CurrencyRateSAT]  WITH CHECK ADD FOREIGN KEY([CurrencyRateVID])
REFERENCES [datavault].[CurrencyRateHUB] ([CurrencyRateVID])
GO
