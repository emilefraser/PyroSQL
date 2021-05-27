SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[UIHistory](
	[id] [uniqueidentifier] NOT NULL,
	[completionTime] [datetime2](7) NOT NULL,
	[taskType] [int] NOT NULL,
	[recordType] [int] NOT NULL,
	[serverid] [uniqueidentifier] NOT NULL,
	[agentid] [uniqueidentifier] NOT NULL,
	[databaseid] [uniqueidentifier] NOT NULL,
	[syncgroupId] [uniqueidentifier] NOT NULL,
	[detailEnumId] [nvarchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[detailStringParameters] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[isWritable] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_ServerId')
CREATE CLUSTERED INDEX [Idx_UIHistory_ServerId] ON [dss].[UIHistory]
(
	[serverid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_AgentId')
CREATE NONCLUSTERED INDEX [Idx_UIHistory_AgentId] ON [dss].[UIHistory]
(
	[agentid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_CompletionTime')
CREATE NONCLUSTERED INDEX [Idx_UIHistory_CompletionTime] ON [dss].[UIHistory]
(
	[completionTime] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_DatabaseId')
CREATE NONCLUSTERED INDEX [Idx_UIHistory_DatabaseId] ON [dss].[UIHistory]
(
	[databaseid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_Id')
CREATE NONCLUSTERED INDEX [Idx_UIHistory_Id] ON [dss].[UIHistory]
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[UIHistory]') AND name = N'Idx_UIHistory_SyncgroupId')
CREATE NONCLUSTERED INDEX [Idx_UIHistory_SyncgroupId] ON [dss].[UIHistory]
(
	[syncgroupId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__UIHistory__isWri__2097C3F2]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[UIHistory] ADD  DEFAULT ((1)) FOR [isWritable]
END
GO
