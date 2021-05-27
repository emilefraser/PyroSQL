SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Batch]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Batch](
	[batch_id] [int] IDENTITY(1,1) NOT NULL,
	[batch_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[batch_start_dt] [datetime] NULL,
	[batch_end_dt] [datetime] NULL,
	[status_id] [int] NULL,
	[last_error_id] [int] NULL,
	[prev_batch_id] [int] NULL,
	[exec_server] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exec_host] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exec_user] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[guid] [bigint] NULL,
	[continue_batch] [bit] NULL,
	[batch_seq] [int] NULL,
 CONSTRAINT [PK_run_id] PRIMARY KEY CLUSTERED 
(
	[batch_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Batch__batch_sta__28EDDE28]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Batch] ADD  DEFAULT (getdate()) FOR [batch_start_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Batch__exec_serv__29E20261]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Batch] ADD  DEFAULT (@@servername) FOR [exec_server]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Batch__exec_host__2AD6269A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Batch] ADD  DEFAULT (host_name()) FOR [exec_host]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Batch__exec_user__2BCA4AD3]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Batch] ADD  DEFAULT (suser_sname()) FOR [exec_user]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Batch__continue___2CBE6F0C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Batch] ADD  DEFAULT ((0)) FOR [continue_batch]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Batch_Batch]') AND parent_object_id = OBJECT_ID(N'[dbo].[Batch]'))
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_Batch] FOREIGN KEY([prev_batch_id])
REFERENCES [dbo].[Batch] ([batch_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Batch_Batch]') AND parent_object_id = OBJECT_ID(N'[dbo].[Batch]'))
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Batch]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Batch_Error]') AND parent_object_id = OBJECT_ID(N'[dbo].[Batch]'))
ALTER TABLE [dbo].[Batch]  WITH CHECK ADD  CONSTRAINT [FK_Batch_Error] FOREIGN KEY([last_error_id])
REFERENCES [dbo].[Error] ([error_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Batch_Error]') AND parent_object_id = OBJECT_ID(N'[dbo].[Batch]'))
ALTER TABLE [dbo].[Batch] CHECK CONSTRAINT [FK_Batch_Error]
GO
