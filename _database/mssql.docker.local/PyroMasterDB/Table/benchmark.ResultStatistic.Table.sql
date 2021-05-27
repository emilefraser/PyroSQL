SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[ResultStatistic]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[ResultStatistic](
	[QueryStatisticId] [int] IDENTITY(1,1) NOT NULL,
	[QueryRun] [int] NOT NULL,
	[QuerySourceId] [int] NOT NULL,
	[Iteration] [smallint] NOT NULL,
	[ScanCount] [int] NULL,
	[ReadLogical] [int] NULL,
	[ReadLogicalLob] [int] NULL,
	[WriteLogical] [int] NULL,
	[ReadPhysical] [int] NULL,
	[ReadPhysicalLob] [int] NULL,
	[WRitePhysical] [int] NULL,
	[ReadAhead] [int] NULL,
	[ReadAheadLob] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_QueryStatistic_QueryStatisticId] PRIMARY KEY CLUSTERED 
(
	[QueryStatisticId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[ResultStatistic]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[ResultStatistic]
(
	[QueryStatisticId] ASC
)
INCLUDE([ScanCount],[ReadLogical],[ReadPhysical],[ReadAhead]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__QueryStat__Creat__379BF032]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[ResultStatistic] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
