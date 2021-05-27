SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SpecialOfferProductLINK](
	[SpecialOfferProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[SpecialOfferVID] [bigint] NOT NULL,
	[ProductVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SpecialOfferProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SpecialOfferVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SpecialOfferVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SpecialOfferVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Produ__5FC911C6]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Produ__68F354A4]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Produ__6B5AC003]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__60BD35FF]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__69E778DD]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SpecialOf__Speci__6C4EE43C]') AND parent_object_id = OBJECT_ID(N'[datavault].[SpecialOfferProductLINK]'))
ALTER TABLE [datavault].[SpecialOfferProductLINK]  WITH CHECK ADD FOREIGN KEY([SpecialOfferVID])
REFERENCES [datavault].[SpecialOfferHUB] ([SpecialOfferVID])
GO
