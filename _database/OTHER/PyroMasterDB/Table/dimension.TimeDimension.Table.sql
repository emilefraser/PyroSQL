SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[TimeDimension]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[TimeDimension](
	[TimeKey] [int] NOT NULL,
	[Hour24] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour24Value] [smallint] NULL,
	[Hour24Min] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour24Full] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12Value] [smallint] NULL,
	[Hour12] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12Min] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Hour12Full] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AmPmCode] [smallint] NULL,
	[AmPm] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[MinuteValue] [smallint] NULL,
	[MinuteCode] [smallint] NULL,
	[Minute] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MinuteFull24] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MinuteFull12] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Minute5Code] [smallint] NULL,
	[Minute10Code] [smallint] NULL,
	[Minute15Code] [smallint] NULL,
	[Minute20Code] [smallint] NULL,
	[Minute30Code] [smallint] NULL,
	[SecondValue] [smallint] NULL,
	[Second] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime_24] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime_12] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FullTime] [time](7) NULL,
 CONSTRAINT [PK_DimTime_TimeKey] PRIMARY KEY CLUSTERED 
(
	[TimeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
