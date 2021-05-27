SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK](
	[SalesPersonIsAKindOfEmployeeVID] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[EmployeeVID] [bigint] NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesPersonIsAKindOfEmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonVID] ASC,
	[EmployeeVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Emplo__4E9E85C4]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Emplo__57C8C8A2]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Emplo__5A303401]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([EmployeeVID])
REFERENCES [datavault].[EmployeeHUB] ([EmployeeVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__4F92A9FD]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__58BCECDB]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5B24583A]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonIsAKindOfEmployeeLINK]'))
ALTER TABLE [datavault].[SalesPersonIsAKindOfEmployeeLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
