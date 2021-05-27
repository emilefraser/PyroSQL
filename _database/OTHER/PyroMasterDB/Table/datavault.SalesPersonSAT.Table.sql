SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesPersonSAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesPersonSAT](
	[SalesPersonVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[Bonus] [money] NOT NULL,
	[CommissionPct] [decimal](18, 0) NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesQuota] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesPersonVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__554B8353]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonSAT]'))
ALTER TABLE [datavault].[SalesPersonSAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5E75C631]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonSAT]'))
ALTER TABLE [datavault].[SalesPersonSAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__60DD3190]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonSAT]'))
ALTER TABLE [datavault].[SalesPersonSAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
