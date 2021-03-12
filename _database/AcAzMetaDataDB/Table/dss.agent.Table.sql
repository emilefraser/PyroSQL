SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[agent]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[agent](
	[id] [uniqueidentifier] NOT NULL,
	[name] [dss].[DISPLAY_NAME] NULL,
	[subscriptionid] [uniqueidentifier] NULL,
	[state] [int] NULL,
	[lastalivetime] [datetime] NULL,
	[is_on_premise] [bit] NOT NULL,
	[version] [dss].[VERSION] NULL,
	[password_hash] [dss].[PASSWORD_HASH] NULL,
	[password_salt] [dss].[PASSWORD_SALT] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dss].[agent]') AND name = N'IX_Agent_SubId_Name')
CREATE UNIQUE NONCLUSTERED INDEX [IX_Agent_SubId_Name] ON [dss].[agent]
(
	[subscriptionid] ASC,
	[name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__agent__id__2A212E2C]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[agent] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__agent__state__2B155265]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[agent] ADD  DEFAULT ((1)) FOR [state]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__agent__subscript]') AND parent_object_id = OBJECT_ID(N'[dss].[agent]'))
ALTER TABLE [dss].[agent]  WITH CHECK ADD  CONSTRAINT [FK__agent__subscript] FOREIGN KEY([subscriptionid])
REFERENCES [dss].[subscription] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__agent__subscript]') AND parent_object_id = OBJECT_ID(N'[dss].[agent]'))
ALTER TABLE [dss].[agent] CHECK CONSTRAINT [FK__agent__subscript]
GO
