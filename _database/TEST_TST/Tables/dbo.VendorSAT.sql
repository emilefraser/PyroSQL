SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[VendorSAT](
	[VendorVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[ActiveFlag] [bit] NULL,
	[PreferredVendorStatus] [bit] NULL,
	[AccountNumber] [varchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreditRating] [tinyint] NOT NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PurchasingWebServiceURL] [varchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

GO
