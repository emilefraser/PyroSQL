SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BusinessEntityAddressLINK](
	[BusinessEntityAddressVID] [bigint] IDENTITY(1,1) NOT NULL,
	[BusinessEntityVID] [bigint] NOT NULL,
	[AddressVID] [bigint] NOT NULL,
	[AddressTypeID] [bigint] NOT NULL
) ON [PRIMARY]

GO
