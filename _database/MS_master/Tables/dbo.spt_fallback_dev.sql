SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[spt_fallback_dev](
	[xserver_name] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[xdttm_ins] [datetime] NOT NULL,
	[xdttm_last_ins_upd] [datetime] NOT NULL,
	[xfallback_low] [int] NULL,
	[xfallback_drive] [char](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[low] [int] NOT NULL,
	[high] [int] NOT NULL,
	[status] [smallint] NOT NULL,
	[name] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[phyname] [varchar](127) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]

GO
