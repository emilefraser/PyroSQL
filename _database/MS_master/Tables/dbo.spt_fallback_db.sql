SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[spt_fallback_db](
	[xserver_name] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[xdttm_ins] [datetime] NOT NULL,
	[xdttm_last_ins_upd] [datetime] NOT NULL,
	[xfallback_dbid] [smallint] NULL,
	[name] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[dbid] [smallint] NOT NULL,
	[status] [smallint] NOT NULL,
	[version] [smallint] NOT NULL
) ON [PRIMARY]

GO
