SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[ResultOperation]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[ResultOperation](
	[QueryResultOperationId] [int] IDENTITY(1,1) NOT NULL,
	[RunExecuteId] [int] NOT NULL,
	[RowsSelect] [int] NULL,
	[RowsInserted] [int] NULL,
	[RowsUpdated] [int] NULL,
	[RowsDeleted] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_QueryResultOperation_QueryResultOperationId] PRIMARY KEY CLUSTERED 
(
	[QueryResultOperationId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[ResultOperation]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[ResultOperation]
(
	[QueryResultOperationId] ASC
)
INCLUDE([RunExecuteId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[ResultOperation]') AND name = N'ncix_02')
CREATE NONCLUSTERED INDEX [ncix_02] ON [benchmark].[ResultOperation]
(
	[RunExecuteId] ASC
)
INCLUDE([RowsSelect],[RowsInserted],[RowsUpdated],[RowsDeleted]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF_QueryResultOperation_QueryResultOperationId]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[ResultOperation] ADD  CONSTRAINT [DF_QueryResultOperation_QueryResultOperationId]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
