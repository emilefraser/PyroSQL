SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[agent_instance]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[agent_instance](
	[id] [uniqueidentifier] NOT NULL,
	[agentid] [uniqueidentifier] NOT NULL,
	[lastalivetime] [datetime] NULL,
	[version] [dss].[VERSION] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[DF__agent_instan__id__1FA39FB9]') AND type = 'D')
BEGIN
ALTER TABLE [dss].[agent_instance] ADD  DEFAULT (newid()) FOR [id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__agent_ins__agent]') AND parent_object_id = OBJECT_ID(N'[dss].[agent_instance]'))
ALTER TABLE [dss].[agent_instance]  WITH CHECK ADD  CONSTRAINT [FK__agent_ins__agent] FOREIGN KEY([agentid])
REFERENCES [dss].[agent] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__agent_ins__agent]') AND parent_object_id = OBJECT_ID(N'[dss].[agent_instance]'))
ALTER TABLE [dss].[agent_instance] CHECK CONSTRAINT [FK__agent_ins__agent]
GO
