SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Transfer]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Transfer](
	[transfer_id] [int] IDENTITY(1,1) NOT NULL,
	[batch_id] [int] NULL,
	[transfer_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[src_obj_id] [int] NULL,
	[target_name] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[transfer_start_dt] [datetime] NULL,
	[transfer_end_dt] [datetime] NULL,
	[status_id] [int] NULL,
	[rec_cnt_src] [int] NULL,
	[rec_cnt_new] [int] NULL,
	[rec_cnt_changed] [int] NULL,
	[rec_cnt_deleted] [int] NULL,
	[last_error_id] [int] NULL,
	[prev_transfer_id] [int] NULL,
	[transfer_seq] [int] NULL,
 CONSTRAINT [PK_transfer_id] PRIMARY KEY CLUSTERED 
(
	[transfer_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Error]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_Error] FOREIGN KEY([last_error_id])
REFERENCES [dbo].[Error] ([error_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Error]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Error]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_Obj] FOREIGN KEY([src_obj_id])
REFERENCES [dbo].[Obj] ([obj_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Obj]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Obj]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Transfer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_Transfer] FOREIGN KEY([prev_transfer_id])
REFERENCES [dbo].[Transfer] ([transfer_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_Transfer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer]'))
ALTER TABLE [dbo].[Transfer] CHECK CONSTRAINT [FK_Transfer_Transfer]
GO
