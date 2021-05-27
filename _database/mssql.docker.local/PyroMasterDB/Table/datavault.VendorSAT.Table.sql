SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[VendorSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[VendorSAT](
	[VendorVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ActiveFlag] [bit] NULL,
	[PreferredVendorStatus] [bit] NULL,
	[AccountNumber] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreditRating] [tinyint] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PurchasingWebServiceURL] [varchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED 
(
	[VendorVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorSAT__Vendo__6E17311D]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorSAT]'))
ALTER TABLE [datavault].[VendorSAT]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorSAT__Vendo__774173FB]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorSAT]'))
ALTER TABLE [datavault].[VendorSAT]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__VendorSAT__Vendo__79A8DF5A]') AND parent_object_id = OBJECT_ID(N'[datavault].[VendorSAT]'))
ALTER TABLE [datavault].[VendorSAT]  WITH CHECK ADD FOREIGN KEY([VendorVID])
REFERENCES [datavault].[VendorHUB] ([VendorVID])
GO
