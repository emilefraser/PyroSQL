SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[Template]') AND type in (N'U'))
BEGIN
CREATE TABLE [static].[Template](
	[template_id] [smallint] NOT NULL,
	[is_etl_template] [bit] NULL,
	[template_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_description] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[template_sql] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_dt] [datetime] NULL,
	[record_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED 
(
	[template_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[static].[Template]') AND name = N'IX_Template_name')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Template_name] ON [static].[Template]
(
	[template_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Template__record__467E410F]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Template] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[static].[DF__Template__record__47726548]') AND type = 'D')
BEGIN
ALTER TABLE [static].[Template] ADD  DEFAULT (suser_sname()) FOR [record_name]
END
GO
