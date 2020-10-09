SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ProductSupplySAT](
	[ProductVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[DaysToManufacture] [int] NOT NULL,
	[ReorderPoint] [int] NOT NULL,
	[SafetyStockLevel] [int] NOT NULL
) ON [PRIMARY]

GO
