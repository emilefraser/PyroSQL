SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Production].[ProductInventory](
	[ProductID] [int] NOT NULL,
	[LocationID] [smallint] NOT NULL,
	[Shelf] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Bin] [tinyint] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
