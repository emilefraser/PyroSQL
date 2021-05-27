SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistorySAT]') AND type in (N'U'))
BEGIN
CREATE TABLE [datavault].[SalesPersonQuotaHistorySAT](
	[SalesPersonQuotaHistoryVID] [bigint] NOT NULL,
	[LoadDateTime] [datetime] NOT NULL,
	[SalesQuota] [money] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesPersonQuotaHistoryVID] ASC,
	[LoadDateTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__54575F1A]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistorySAT]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5D81A1F8]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistorySAT]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[datavault].[FK__SalesPers__Sales__5FE90D57]') AND parent_object_id = OBJECT_ID(N'[datavault].[SalesPersonQuotaHistorySAT]'))
ALTER TABLE [datavault].[SalesPersonQuotaHistorySAT]  WITH CHECK ADD FOREIGN KEY([SalesPersonQuotaHistoryVID])
REFERENCES [datavault].[SalesPersonQuotaHistoryHUB] ([SalesPersonQuotaHistoryVID])
GO
