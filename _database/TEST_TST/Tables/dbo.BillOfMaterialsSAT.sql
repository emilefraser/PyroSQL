SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BillOfMaterialsSAT](
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[BOMLevel] [smallint] NOT NULL,
	[PerAssemblyQty] [decimal](18, 0) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[UnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY]

GO
