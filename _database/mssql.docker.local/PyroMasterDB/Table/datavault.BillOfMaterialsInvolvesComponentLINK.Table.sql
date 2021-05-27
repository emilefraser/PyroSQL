SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK](
	[BillOfMaterialsInvolvesComponentVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[ComponentProductVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BillOfMaterialsInvolvesComponentVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ComponentProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ComponentProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ComponentProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__5768D5EF]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__609318CD]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__62FA842C]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Compo__585CFA28]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([ComponentProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Compo__61873D06]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([ComponentProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Compo__63EEA865]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesComponentLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesComponentLINK]  WITH CHECK ADD FOREIGN KEY([ComponentProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
