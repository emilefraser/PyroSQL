SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[WorkOrderIsForProductLINK](
	[WorkOrderIsForProductVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[ProductVID] [bigint] NOT NULL,
	[WorkOrderVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkOrderIsForProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[WorkOrderVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[WorkOrderVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[WorkOrderVID] ASC,
	[ProductVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__Produ__6F0B5556]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__Produ__78359834]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__Produ__7A9D0393]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([ProductVID])
REFERENCES [datavault].[ProductHUB] ([ProductVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__6FFF798F]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7929BC6D]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__WorkOrder__WorkO__7B9127CC]') AND parent_object_id = OBJECT_ID(N'[datavault].[WorkOrderIsForProductLINK]'))
ALTER TABLE [datavault].[WorkOrderIsForProductLINK]  WITH CHECK ADD FOREIGN KEY([WorkOrderVID])
REFERENCES [datavault].[WorkOrderHUB] ([WorkOrderVID])
GO
