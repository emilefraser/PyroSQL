SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CurrencyRateSAT](
	[CurrencyRateVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AverageRate] [money] NOT NULL,
	[CurrencyRateDate] [datetime] NOT NULL,
	[EndOfDayRate] [money] NOT NULL,
	[FromCurrencyCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ToCurrencyCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
