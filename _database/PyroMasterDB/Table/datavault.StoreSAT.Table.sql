SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[StoreSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[StoreSAT](
	[StoreVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Demographics] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[StoreVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreSAT__StoreV__648DC6E3]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreSAT]'))
ALTER TABLE [datavault].[StoreSAT]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreSAT__StoreV__6DB809C1]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreSAT]'))
ALTER TABLE [datavault].[StoreSAT]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__StoreSAT__StoreV__701F7520]') AND parent_object_id = OBJECT_ID(N'[datavault].[StoreSAT]'))
ALTER TABLE [datavault].[StoreSAT]  WITH CHECK ADD FOREIGN KEY([StoreVID])
REFERENCES [datavault].[StoreHUB] ([StoreVID])
GO
