SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[AddressSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[AddressSAT](
	[AddressVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AddressLine1] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CityName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PostalCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StateProvinceID] [bigint] NOT NULL,
	[AddressLine2] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpatialLocation] [geography] NULL,
PRIMARY KEY CLUSTERED 
(
	[AddressVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__AddressSA__Addre__5674B1B6]') AND parent_object_id = OBJECT_ID(N'[datavault].[AddressSAT]'))
ALTER TABLE [datavault].[AddressSAT]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__AddressSA__Addre__5F9EF494]') AND parent_object_id = OBJECT_ID(N'[datavault].[AddressSAT]'))
ALTER TABLE [datavault].[AddressSAT]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__AddressSA__Addre__62065FF3]') AND parent_object_id = OBJECT_ID(N'[datavault].[AddressSAT]'))
ALTER TABLE [datavault].[AddressSAT]  WITH CHECK ADD FOREIGN KEY([AddressVID])
REFERENCES [datavault].[AddressHUB] ([AddressVID])
GO
