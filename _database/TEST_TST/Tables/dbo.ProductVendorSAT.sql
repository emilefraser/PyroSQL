SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductVendorSAT](
	[ProductVendorVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[AverageLeadTime] [int] NOT NULL,
	[MaxOrderQty] [int] NOT NULL,
	[MinOrderQty] [int] NOT NULL,
	[OnOrderQty] [int] NOT NULL,
	[StandardPrice] [money] NOT NULL,
	[UnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[LastReceiptCost] [money] NULL,
	[LastReceiptDate] [datetime] NULL
) ON [PRIMARY]

GO
