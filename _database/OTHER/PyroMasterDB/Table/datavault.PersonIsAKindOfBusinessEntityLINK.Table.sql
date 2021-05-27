SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK](
	[PersonIsAKindOfBusinessEntityVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[PersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonIsAKindOfBusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Busin__043B7C66]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Busin__0D65BF44]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Busin__0FCD2AA3]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Perso__052FA09F]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Perso__0E59E37D]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PersonIsA__Perso__10C14EDC]') AND parent_object_id = OBJECT_ID(N'[datavault].[PersonIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[PersonIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([PersonVID])
REFERENCES [datavault].[PersonHUB] ([PersonVID])
GO
