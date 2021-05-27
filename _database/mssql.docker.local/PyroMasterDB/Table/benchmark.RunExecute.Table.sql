SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[RunExecute]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[RunExecute](
	[RunExecuteId] [int] IDENTITY(1,1) NOT NULL,
	[QueryDefineId] [int] NOT NULL,
	[RunDefineId] [int] NOT NULL,
	[IterationNumber] [smallint] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_RunExecute_RunExecuteId] PRIMARY KEY CLUSTERED 
(
	[RunExecuteId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[RunExecute]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[RunExecute]
(
	[RunExecuteId] ASC
)
INCLUDE([QueryDefineId],[RunDefineId],[IterationNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF_benchmark_RunExecute]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[RunExecute] ADD  CONSTRAINT [DF_benchmark_RunExecute]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
