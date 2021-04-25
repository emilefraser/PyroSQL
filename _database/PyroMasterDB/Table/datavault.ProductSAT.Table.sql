SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductSAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[FinishedGoodsFlag] [bit] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ProductNumber] [varchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSA__Produ__2690946A]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSAT]'))
ALTER TABLE [datavault].[ProductSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSA__Produ__2FBAD748]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSAT]'))
ALTER TABLE [datavault].[ProductSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductSA__Produ__322242A7]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductSAT]'))
ALTER TABLE [datavault].[ProductSAT]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
