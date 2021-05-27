SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK](
	[BillOfMaterialsInvolvesProductAssemblyVI] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[BillOfMaterialsVID] [bigint] NOT NULL,
	[ProductAssemblyProductVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BillOfMaterialsInvolvesProductAssemblyVI] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ProductAssemblyProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ProductAssemblyProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[BillOfMaterialsVID] ASC,
	[ProductAssemblyProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__59511E61]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__627B613F]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__BillO__64E2CC9E]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([BillOfMaterialsVID])
REFERENCES [datavault].[BillOfMaterialsHUB] ([BillOfMaterialsVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Produ__5A45429A]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([ProductAssemblyProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Produ__636F8578]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([ProductAssemblyProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__BillOfMat__Produ__65D6F0D7]') AND parent_object_id = OBJECT_ID(N'[datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]'))
ALTER TABLE [datavault].[BillOfMaterialsInvolvesProductAssemblyLINK]  WITH CHECK ADD FOREIGN KEY([ProductAssemblyProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
