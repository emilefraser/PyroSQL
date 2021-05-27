SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dss].[taskdependency]') AND type in (N'U'))
BEGIN
CREATE TABLE [dss].[taskdependency](
	[nexttaskid] [uniqueidentifier] NOT NULL,
	[prevtaskid] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_TaskTask] PRIMARY KEY CLUSTERED 
(
	[nexttaskid] ASC,
	[prevtaskid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__taskdepen__nextt]') AND parent_object_id = OBJECT_ID(N'[dss].[taskdependency]'))
ALTER TABLE [dss].[taskdependency]  WITH CHECK ADD  CONSTRAINT [FK__taskdepen__nextt] FOREIGN KEY([nexttaskid])
REFERENCES [dss].[task] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__taskdepen__nextt]') AND parent_object_id = OBJECT_ID(N'[dss].[taskdependency]'))
ALTER TABLE [dss].[taskdependency] CHECK CONSTRAINT [FK__taskdepen__nextt]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__taskdepen__prevt]') AND parent_object_id = OBJECT_ID(N'[dss].[taskdependency]'))
ALTER TABLE [dss].[taskdependency]  WITH CHECK ADD  CONSTRAINT [FK__taskdepen__prevt] FOREIGN KEY([prevtaskid])
REFERENCES [dss].[task] ([id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dss].[FK__taskdepen__prevt]') AND parent_object_id = OBJECT_ID(N'[dss].[taskdependency]'))
ALTER TABLE [dss].[taskdependency] CHECK CONSTRAINT [FK__taskdepen__prevt]
GO
