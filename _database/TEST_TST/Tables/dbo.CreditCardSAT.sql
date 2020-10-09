SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CreditCardSAT](
	[CreditCardVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[CardNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CardType] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ExpMonth] [tinyint] NOT NULL,
	[ExpYear] [smallint] NOT NULL
) ON [PRIMARY]

GO
