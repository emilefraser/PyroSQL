SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Obj_dep]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Obj_dep](
	[obj_id] [int] NOT NULL,
	[dep_obj_id] [int] NOT NULL,
	[dep_type_id] [smallint] NOT NULL,
	[top_sort_rank] [smallint] NULL,
	[delete_dt] [datetime] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK__Obj_dep__7C69C680D927C550] PRIMARY KEY CLUSTERED 
(
	[obj_id] ASC,
	[dep_obj_id] ASC,
	[dep_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Obj_dep__record___3C00B29C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Obj_dep] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Obj_dep__record___3CF4D6D5]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Obj_dep] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Dep_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep]  WITH CHECK ADD  CONSTRAINT [FK_Obj_dep_Dep_type] FOREIGN KEY([dep_type_id])
REFERENCES [static].[Dep_type] ([dep_type_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Dep_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Dep_type]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep]  WITH CHECK ADD  CONSTRAINT [FK_Obj_dep_Obj] FOREIGN KEY([obj_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Obj]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Obj1]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep]  WITH CHECK ADD  CONSTRAINT [FK_Obj_dep_Obj1] FOREIGN KEY([dep_obj_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Obj_dep_Obj1]') AND parent_object_id = OBJECT_ID(N'[dbo].[Obj_dep]'))
ALTER TABLE [dbo].[Obj_dep] CHECK CONSTRAINT [FK_Obj_dep_Obj1]
GO
