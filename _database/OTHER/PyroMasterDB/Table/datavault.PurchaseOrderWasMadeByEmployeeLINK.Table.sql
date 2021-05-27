SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK](
	[PurchaseOrderWasMadeByEmployeeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[PurchaseOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PurchaseOrderWasMadeByEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PurchaseOrderVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Emplo__33EA8F88]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Emplo__3D14D266]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Emplo__3F7C3DC5]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__34DEB3C1]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__3E08F69F]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__PurchaseO__Purch__407061FE]') AND parent_object_id = OBJECT_ID(N'[datavault].[PurchaseOrderWasMadeByEmployeeLINK]'))
ALTER TABLE [datavault].[PurchaseOrderWasMadeByEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([PurchaseOrderVID])
REFERENCES [datavault].[PurchaseOrderHUB] ([PurchaseOrderVID])
GO
