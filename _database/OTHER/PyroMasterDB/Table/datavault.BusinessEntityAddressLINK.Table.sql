SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[BusinessEntityAddressLINK](
	[BusinessEntityAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[AddressVID] [bigint] NOT NULL,
	[AddressTypeID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BusinessEntityAddressVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[AddressVID] ASC,
	[AddressTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[AddressVID] ASC,
	[AddressTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BusinessEntityVID] ASC,
	[AddressVID] ASC,
	[AddressTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Addre__5C2D8B0C]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Addre__6557CDEA]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Addre__67BF3949]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__5D21AF45]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__664BF223]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BusinessE__Busin__68B35D82]') AND parent_object_id = OBJECT_ID(N'[datavault].[BusinessEntityAddressLINK]'))
ALTER TABLE [datavault].[BusinessEntityAddressLINK]  WITH CHECK ADD FOREIGN KEY([BusinessEntityVID])
REFERENCES [datavault].[BusinessEntityHUB] ([BusinessEntityVID])
GO
