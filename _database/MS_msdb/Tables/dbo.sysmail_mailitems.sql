SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysmail_mailitems](
	[mailitem_id] [int] IDENTITY(1,1) NOT NULL,
	[profile_id] [int] NOT NULL,
	[recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[copy_recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[blind_copy_recipients] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[subject] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[from_address] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[reply_to] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[body_format] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[importance] [varchar](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sensitivity] [varchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[file_attachments] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[attachment_encoding] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[query] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[execute_query_database] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[attach_query_result_as_file] [bit] NULL,
	[query_result_header] [bit] NULL,
	[query_result_width] [int] NULL,
	[query_result_separator] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[exclude_query_output] [bit] NULL,
	[append_query_error] [bit] NULL,
	[send_request_date] [datetime] NOT NULL,
	[send_request_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sent_account_id] [int] NULL,
	[sent_status] [tinyint] NULL,
	[sent_date] [datetime] NULL,
	[last_mod_date] [datetime] NOT NULL,
	[last_mod_user] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
