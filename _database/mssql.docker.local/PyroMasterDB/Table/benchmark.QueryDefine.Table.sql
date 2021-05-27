SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[QueryDefine]') AND type in (N'U'))
BEGIN
CREATE TABLE [benchmark].[QueryDefine](
	[QueryDefineId] [int] IDENTITY(1,1) NOT NULL,
	[QueryDefineCode] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[QueryDefineName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QueryDefinition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_benchmark_QuerySource_QuerySourceId] PRIMARY KEY CLUSTERED 
(
	[QueryDefineId] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[benchmark].[QueryDefine]') AND name = N'ncix_01')
CREATE NONCLUSTERED INDEX [ncix_01] ON [benchmark].[QueryDefine]
(
	[QueryDefineCode] ASC
)
INCLUDE([QueryDefinition]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[DF__QuerySour__Creat__0F8DFED8]') AND type = 'D')
BEGIN
ALTER TABLE [benchmark].[QueryDefine] ADD  CONSTRAINT [DF__QuerySour__Creat__0F8DFED8]  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
