SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK](
	[SalesPersonQuotaHistoryInvolvesSalesPers] [bigint] IDENTITY(1,1) NOT NULL,
	[FirstLoadDateTime] [datetime] NULL,
	[SalesPersonQuotaHistoryVID] [bigint] NOT NULL,
	[SalesPersonVID] [bigint] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesPersonQuotaHistoryInvolvesSalesPers] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonQuotaHistoryVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonQuotaHistoryVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SalesPersonQuotaHistoryVID] ASC,
	[SalesPersonVID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__526F16A8]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__53633AE1]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5B995986]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5C8D7DBF]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5E00C4E5]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5EF4E91E]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistoryInvolvesSalesPersonLINK]  WITH CHECK ADD FOREIGN KEY([SalesPersonVID])
REFERENCES [datavault].[SalesPersonHUB] ([SalesPersonVID])
GO
