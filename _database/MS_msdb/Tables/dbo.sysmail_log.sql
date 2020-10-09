SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_log](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[event_type] [int] NOT NULL,
	[log_date] [datetime] NOT NULL,
	[description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[process_id] [int] NULL,
	[mailitem_id] [int] NULL,
	[account_id] [int] NULL,
	[last_mod_date] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
