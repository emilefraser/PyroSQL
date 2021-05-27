SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Transfer_log]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Transfer_log](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[log_dt] [datetime] NULL,
	[msg] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[transfer_id] [int] NULL,
	[log_level_id] [smallint] NULL,
	[log_type_id] [smallint] NULL,
	[exec_sql] [bit] NULL,
 CONSTRAINT [PK_log_id] PRIMARY KEY CLUSTERED 
(
	[log_id] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF__Transfer___log_d__41B98BF2]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[Transfer_log] ADD  DEFAULT (getdate()) FOR [log_dt]
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Log_level]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_log_Log_level] FOREIGN KEY([log_level_id])
REFERENCES [static].[Log_level] ([log_level_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Log_level]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Log_level]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Log_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_log_Log_type] FOREIGN KEY([log_type_id])
REFERENCES [static].[Log_type] ([log_type_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Log_type]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Log_type]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Transfer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log]  WITH CHECK ADD  CONSTRAINT [FK_Transfer_log_Transfer] FOREIGN KEY([transfer_id])
REFERENCES [dbo].[Transfer] ([transfer_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transfer_log_Transfer]') AND parent_object_id = OBJECT_ID(N'[dbo].[Transfer_log]'))
ALTER TABLE [dbo].[Transfer_log] CHECK CONSTRAINT [FK_Transfer_log_Transfer]
GO
