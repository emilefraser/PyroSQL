SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_account](
	[account_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[email_address] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[display_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[replyto_address] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_mod_datetime] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
