SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SpecialOfferSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SpecialOfferSAT](
	[SpecialOfferVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Category] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPct] [decimal](18, 0) NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[MaxQty] [int] NOT NULL,
	[MinQty] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[Type] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SpecialOfferVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__61B15A38]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferSAT]'))
ALTER TABLE [datavault].[SpecialOfferSAT]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__6ADB9D16]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferSAT]'))
ALTER TABLE [datavault].[SpecialOfferSAT]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__6D430875]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferSAT]'))
ALTER TABLE [datavault].[SpecialOfferSAT]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
