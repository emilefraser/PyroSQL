SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductVendorLINK](
	[ProductVendorVID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductVID] [bigint] NOT NULL,
	[VendorVID] [bigint] NOT NULL
) ON [PRIMARY]

GO
