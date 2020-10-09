SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductInventorySAT](
	[ProductInventoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Bin] [tinyint] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Shelf] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
