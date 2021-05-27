SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Col_hist]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Col_hist](
	[column_id] [int] IDENTITY(1,1) NOT NULL,
	[eff_dt] [datetime] NOT NULL,
	[obj_id] [int] NOT NULL,
	[column_name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[prefix] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[entity_name] [varchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[foreign_column_id] [int] NULL,
	[ordinal_position] [smallint] NULL,
	[is_nullable] [bit] NULL,
	[data_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[max_len] [int] NULL,
	[numeric_precision] [int] NULL,
	[numeric_scale] [int] NULL,
	[column_type_id] [int] NULL,
	[src_column_id] [int] NULL,
	[delete_dt] [datetime] NULL,
	[record_dt] [datetime] NULL,
	[record_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[chksum] [int] NOT NULL,
	[transfer_id] [int] NULL,
	[part_of_unique_index] [bit] NULL,
 CONSTRAINT [PK__Hst_column] PRIMARY KEY CLUSTERED 
(
	[column_id] ASC,
	[eff_dt] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Col_hist__record__2EA6B77E]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Col_hist] ADD  DEFAULT (getdate()) FOR [record_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Col_hist__record__2F9ADBB7]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Col_hist] ADD  DEFAULT (suser_sname()) FOR [record_user]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Col_hist__part_o__308EFFF0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Col_hist] ADD  DEFAULT ((0)) FOR [part_of_unique_index]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Col_hist_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Col_hist]'))
ALTER TABLE [dbo].[Col_hist]  WITH CHECK ADD  CONSTRAINT [FK_Col_hist_Obj] FOREIGN KEY([obj_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Col_hist_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Col_hist]'))
ALTER TABLE [dbo].[Col_hist] CHECK CONSTRAINT [FK_Col_hist_Obj]
GO
