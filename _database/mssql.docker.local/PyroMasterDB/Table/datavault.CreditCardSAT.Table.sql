SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CreditCardSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CreditCardSAT](
	[CreditCardVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CardNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpMonth] [tinyint] NOT NULL,
	[ExpYear] [smallint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CreditCardVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CreditCar__Credi__5FFE1BF0]') AND parent_object_id = OBJECT_ID(N'[datavault].[CreditCardSAT]'))
ALTER TABLE [datavault].[CreditCardSAT]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CreditCar__Credi__69285ECE]') AND parent_object_id = OBJECT_ID(N'[datavault].[CreditCardSAT]'))
ALTER TABLE [datavault].[CreditCardSAT]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CreditCar__Credi__6B8FCA2D]') AND parent_object_id = OBJECT_ID(N'[datavault].[CreditCardSAT]'))
ALTER TABLE [datavault].[CreditCardSAT]  WITH CHECK ADD FOREIGN KEY([CreditCardVID])
REFERENCES [datavault].[CreditCardHUB] ([CreditCardVID])
GO
