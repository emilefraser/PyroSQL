SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[BillOfMaterialsSAT](
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[BOMLevel] [smallint] NOT NULL,
	[PerAssemblyQty] [decimal](18, 0) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[UnitMeasureCode] [char](3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EndDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__5B3966D3]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsSAT]'))
ALTER TABLE [datavault].[BillOfMaterialsSAT]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__6463A9B1]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsSAT]'))
ALTER TABLE [datavault].[BillOfMaterialsSAT]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__66CB1510]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsSAT]'))
ALTER TABLE [datavault].[BillOfMaterialsSAT]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
