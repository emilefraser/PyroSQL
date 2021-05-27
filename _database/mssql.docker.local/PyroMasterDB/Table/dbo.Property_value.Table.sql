SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Property_value]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Property_value](
	[property_id] [int] NOT NULL,
	[obj_id] [int] NOT NULL,
	[value] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_Property_Value] PRIMARY KEY CLUSTERED 
(
	[property_id] ASC,
	[obj_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Property___recor__3DE8FB0E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Property_value] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Property___recor__3EDD1F47]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Property_value] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Property_value_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Property_value]'))
ALTER TABLE [dbo].[Property_value]  WITH CHECK ADD  CONSTRAINT [FK_Property_value_Obj] FOREIGN KEY([obj_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Property_value_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Property_value]'))
ALTER TABLE [dbo].[Property_value] CHECK CONSTRAINT [FK_Property_value_Obj]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Property_value_Property]') AND parent_object_id = OBJECT_ID(N'[dbo].[Property_value]'))
ALTER TABLE [dbo].[Property_value]  WITH CHECK ADD  CONSTRAINT [FK_Property_value_Property] FOREIGN KEY([property_id])
REFERENCES [static].[Property] ([property_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Property_value_Property]') AND parent_object_id = OBJECT_ID(N'[dbo].[Property_value]'))
ALTER TABLE [dbo].[Property_value] CHECK CONSTRAINT [FK_Property_value_Property]
GO
