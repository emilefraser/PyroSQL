SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductInventorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductInventorySAT](
	[ProductInventoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Bin] [tinyint] NOT NULL,
	[Quantity] [int] NOT NULL,
	[Shelf] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductInventoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__1471E42F]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventorySAT]'))
ALTER TABLE [datavault].[ProductInventorySAT]  WITH CHECK ADD FOREIGN KEY([ProductInventoryVID])
REFERENCES [datavault].[ProductInventoryLINK] ([ProductInventoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__1D9C270D]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventorySAT]'))
ALTER TABLE [datavault].[ProductInventorySAT]  WITH CHECK ADD FOREIGN KEY([ProductInventoryVID])
REFERENCES [datavault].[ProductInventoryLINK] ([ProductInventoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductIn__Produ__2003926C]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductInventorySAT]'))
ALTER TABLE [datavault].[ProductInventorySAT]  WITH CHECK ADD FOREIGN KEY([ProductInventoryVID])
REFERENCES [datavault].[ProductInventoryLINK] ([ProductInventoryVID])
GO
