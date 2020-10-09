SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[sysoperators](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[enabled] [tinyint] NOT NULL,
	[email_address] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_email_date] [int] NOT NULL,
	[last_email_time] [int] NOT NULL,
	[pager_address] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_pager_date] [int] NOT NULL,
	[last_pager_time] [int] NOT NULL,
	[weekday_pager_start_time] [int] NOT NULL,
	[weekday_pager_end_time] [int] NOT NULL,
	[saturday_pager_start_time] [int] NOT NULL,
	[saturday_pager_end_time] [int] NOT NULL,
	[sunday_pager_start_time] [int] NOT NULL,
	[sunday_pager_end_time] [int] NOT NULL,
	[pager_days] [tinyint] NOT NULL,
	[netsend_address] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[last_netsend_date] [int] NOT NULL,
	[last_netsend_time] [int] NOT NULL,
	[category_id] [int] NOT NULL
) ON [PRIMARY]

GO
