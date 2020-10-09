SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [MASTER].[TimeDimension](
	[TimeKey] [int] NOT NULL,
	[Hour24] [smallint] NULL,
	[Hour24_String] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour24_MinString] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour24_FullString] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12] [smallint] NULL,
	[Hour12_String] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12_MinString] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12_FullString] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AMPM_Code] [smallint] NULL,
	[AMPM_String] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Minute] [smallint] NULL,
	[Minute_Code] [smallint] NULL,
	[Minute_String] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Minute_FullString24] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Minute_FullString12] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Minute5_Code] [smallint] NULL,
	[Minute10_Code] [smallint] NULL,
	[Minute15_Code] [smallint] NULL,
	[Minute20_Code] [smallint] NULL,
	[Minute30_Code] [smallint] NULL,
	[Second] [smallint] NULL,
	[Second_String] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime_String24] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime_String12] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime] [time](7) NULL
) ON [PRIMARY]

GO
