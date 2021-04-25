SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[CustomerIsPersonLINK](
	[CustomerIsPersonVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[CustomerVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerIsPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerVID] ASC,
	[PersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__63CEACD4]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__6CF8EFB2]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Custo__6F605B11]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([CustomerVID])
REFERENCES [datavault].[CustomerHUB] ([CustomerVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Perso__64C2D10D]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Perso__6DED13EB]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__CustomerI__Perso__70547F4A]') AND parent_object_id = OBJECT_ID(N'[datavault].[CustomerIsPersonLINK]'))
ALTER TABLE [datavault].[CustomerIsPersonLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
