SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[logmarkhistory](
	[database_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[mark_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[user_name] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[lsn] [numeric](25, 0) NOT NULL,
	[mark_time] [datetime] NOT NULL
) ON [PRIMARY]

GO
