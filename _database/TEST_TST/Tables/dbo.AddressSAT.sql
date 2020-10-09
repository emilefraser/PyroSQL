SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AddressSAT](
	[AddressVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AddressLine1] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CityName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PostalCode] [varchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StateProvinceID] [bigint] NOT NULL,
	[AddressLine2] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SpatialLocation] [geography] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
