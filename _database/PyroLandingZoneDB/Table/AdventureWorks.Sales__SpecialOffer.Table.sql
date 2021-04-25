SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AdventureWorks].[Sales__SpecialOffer]') AND type in (N'U'))
BEGIN
CREATE TABLE [AdventureWorks].[Sales__SpecialOffer](
	[SpecialOfferID] [int] NOT NULL,
	[Description] [nvarchar](510) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DiscountPct] [smallmoney] NOT NULL,
	[Type] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Category] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[MinQty] [int] NOT NULL,
	[MaxQty] [int] NULL,
	[rowguid] [uniqueidentifier] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
END
GO
