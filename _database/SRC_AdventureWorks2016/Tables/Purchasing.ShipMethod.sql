SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [Purchasing].[ShipMethod](
	[ShipMethodID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ShipBase] [money] NOT NULL,
	[ShipRate] [money] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
