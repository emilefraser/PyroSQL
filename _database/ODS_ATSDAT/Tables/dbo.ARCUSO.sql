SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ARCUSO](
	[IDCUST] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OPTFIELD] [char](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUDTDATE] [decimal](9, 0) NULL,
	[AUDTTIME] [decimal](9, 0) NULL,
	[AUDTUSER] [char](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AUDTORG] [char](6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VALUE] [char](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TYPE] [smallint] NULL,
	[LENGTH] [smallint] NULL,
	[DECIMALS] [smallint] NULL,
	[ALLOWNULL] [smallint] NULL,
	[VALIDATE] [smallint] NULL,
	[SWSET] [smallint] NULL
) ON [PRIMARY]

GO
