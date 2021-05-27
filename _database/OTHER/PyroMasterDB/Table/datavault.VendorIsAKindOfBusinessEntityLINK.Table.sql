SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK](
	[VendorIsAKindOfBusinessEntityVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[VendorVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VendorIsAKindOfBusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[VendorVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[VendorVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[VendorVID] ASC,
	[BusinessEntityVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Busin__6C2EE8AB]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Busin__75592B89]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Busin__77C096E8]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Vendo__6D230CE4]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Vendo__764D4FC2]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorIsA__Vendo__78B4BB21]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorIsAKindOfBusinessEntityLINK]'))
ALTER TABLE [datavault].[VendorIsAKindOfBusinessEntityLINK]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
