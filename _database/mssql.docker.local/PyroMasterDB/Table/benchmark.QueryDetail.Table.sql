SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[QueryDetail]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[QueryDetail](
	[QueryDetailId] [int] IDENTITY(1,1) NOT NULL,
	[SqlHandle] [varbinary](64) NOT NULL,
	[PlanHandle] [varbinary](64) NOT NULL,
	[QueryHash] [binary](8) NULL,
	[QueryPlanHash] [binary](8) NULL,
	[QueryText] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QueryPlanXML] [xml] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_QueryHandle_QueryHandleId] PRIMARY KEY CLUSTERED 
(
	[QueryDetailId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[QueryDetail]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[QueryDetail]
(
	[SqlHandle] ASC
)
INCLUDE([PlanHandle],[QueryHash],[QueryPlanHash]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__QueryDeta__Creat__31E316DC]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[QueryDetail] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
