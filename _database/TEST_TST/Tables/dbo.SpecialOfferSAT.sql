SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SpecialOfferSAT](
	[SpecialOfferVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPct] [decimal](18, 0) NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[MaxQty] [int] NOT NULL,
	[MinQty] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[Type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
