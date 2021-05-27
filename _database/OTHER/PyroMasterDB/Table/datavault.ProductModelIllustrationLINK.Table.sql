SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[ProductModelIllustrationLINK](
	[ProductModelIllustrationVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductModelVID] [bigint] NOT NULL,
	[IllustrationVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductModelIllustrationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[IllustrationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[IllustrationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductModelVID] ASC,
	[IllustrationVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Illus__1A2ABD85]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Illus__23550063]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Illus__25BC6BC2]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([IllustrationVID])
REFERENCES [datavault].[IllustrationHUB] ([IllustrationVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__1B1EE1BE]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__2449249C]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__ProductMo__Produ__26B08FFB]') AND parent_object_id = OBJECT_ID(N'[datavault].[ProductModelIllustrationLINK]'))
ALTER TABLE [datavault].[ProductModelIllustrationLINK]  WITH CHECK ADD FOREIGN KEY([ProductModelVID])
REFERENCES [datavault].[ProductModelHUB] ([ProductModelVID])
GO
