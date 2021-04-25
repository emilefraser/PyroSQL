SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Obj]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Obj](
	[obj_id] [int] IDENTITY(1,1) NOT NULL,
	[obj_type_id] [int] NOT NULL,
	[server_type_id] [int] NULL,
	[obj_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[parent_id] [int] NULL,
	[scope] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[identifier] [int] NULL,
	[template_id] [smallint] NULL,
	[delete_dt] [datetime] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prefix] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[obj_name_no_prefix] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK__Obj] PRIMARY KEY CLUSTERED 
(
	[obj_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Obj__server_type__392445F1]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Obj] ADD  DEFAULT ((10)) FOR [server_type_id]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Obj__record_dt__3A186A2A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Obj] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Obj__record_user__3B0C8E63]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Obj] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__obj__obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj]'))
ALTER TABLE [dbo].[Obj]  WITH CHECK ADD  CONSTRAINT [FK__obj__obj] FOREIGN KEY([parent_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__obj__obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj]'))
ALTER TABLE [dbo].[Obj] CHECK CONSTRAINT [FK__obj__obj]
GO
