SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[systargetservers](
	[server_id] [int] IDENTITY(1,1) NOT NULL,
	[server_name] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[location] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[time_zone_adjustment] [int] NOT NULL,
	[enlist_date] [datetime] NOT NULL,
	[last_poll_date] [datetime] NOT NULL,
	[status] [int] NOT NULL,
	[local_time_at_last_poll] [datetime] NOT NULL,
	[enlisted_by_nt_user] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[poll_interval] [int] NOT NULL
) ON [PRIMARY]

GO
