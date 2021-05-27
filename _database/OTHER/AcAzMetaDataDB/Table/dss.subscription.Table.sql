SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[subscription]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[subscription](
	[id] [uniqueidentifier] NOT NULL,
	[name] [dss].[DISPLAY_NAME] NULL,
	[creationtime] [datetime] NULL,
	[lastlogintime] [datetime] NULL,
	[tombstoneretentionperiodindays] [int] NOT NULL,
	[policyid] [int] NULL,
	[subscriptionstate] [tinyint] NOT NULL,
	[WindowsAzureSubscriptionId] [uniqueidentifier] NULL,
	[EnableDetailedProviderTracing] [bit] NULL,
	[syncserveruniquename] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[version] [dss].[VERSION] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[subscription]') AND name = N'IX_SyncServerUniqueName')
CREATE UNIQUE NONCLUSTERED INDEX [IX_SyncServerUniqueName] ON [dss].[subscription]
(
	[syncserveruniquename] ASC
)
WHERE ([syncserveruniquename] IS NOT NULL)
WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__subscription__id__09B45E9A]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[subscription] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__subscript__polic__0AA882D3]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[subscription] ADD  DEFAULT ((0)) FOR [policyid]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__subscript__subsc__0B9CA70C]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[subscription] ADD  DEFAULT ((0)) FOR [subscriptionstate]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__subscript__Enabl__0C90CB45]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[subscription] ADD  DEFAULT ((0)) FOR [EnableDetailedProviderTracing]
END
GO
