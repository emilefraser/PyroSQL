SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[Vendor](
	[BusinessEntityID] [int] NOT NULL,
	[AccountNumber] [dbo].[AccountNumber] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CreditRating] [tinyint] NOT NULL,
	[PreferredVendorStatus] [dbo].[Flag] NOT NULL,
	[ActiveFlag] [dbo].[Flag] NOT NULL,
	[PurchasingWebServiceURL] [nvarchar](1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
