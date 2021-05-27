SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[ResultTime]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[ResultTime](
	[QueryResultTimeId] [int] IDENTITY(1,1) NOT NULL,
	[RunExecuteId] [int] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL,
	[QueryDuration]  AS (datediff(second,[StartDT],[EndDT])),
	[TimeCPU] [bigint] NULL,
	[TimeElapsed] [bigint] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_QueryResultTime_QueryResultTimeId] PRIMARY KEY CLUSTERED 
(
	[QueryResultTimeId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[ResultTime]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[ResultTime]
(
	[QueryResultTimeId] ASC
)
INCLUDE([RunExecuteId],[StartDT],[EndDT]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[ResultTime]') AND name = N'ncix_02')
CREATE NONCLUSTERED INDEX [ncix_02] ON [benchmark].[ResultTime]
(
	[RunExecuteId] ASC
)
INCLUDE([StartDT],[EndDT]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__QueryResu__Creat__182344D9]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[ResultTime] ADD  CONSTRAINT [DF__QueryResu__Creat__182344D9]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
