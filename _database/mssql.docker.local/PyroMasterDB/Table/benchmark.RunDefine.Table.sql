SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[RunDefine]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[RunDefine](
	[RunDefineId] [int] IDENTITY(1,1) NOT NULL,
	[QueryDefineIdList] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NumberOfIteration] [smallint] NOT NULL,
	[DelayBetweenIteration] [int] NULL,
	[TopNRecord] [int] NULL,
	[IsColdCache] [bit] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_RunDefine_RunDefineId] PRIMARY KEY CLUSTERED 
(
	[RunDefineId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[RunDefine]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[RunDefine]
(
	[RunDefineId] ASC
)
INCLUDE([QueryDefineIdList],[NumberOfIteration]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__RunDefine__IsCol__59F10836]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[RunDefine] ADD  DEFAULT ((1)) FOR [IsColdCache]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__RunDefine__Create__126A6B83]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[RunDefine] ADD  CONSTRAINT [DF__RunDefine__Create__126A6B83]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
