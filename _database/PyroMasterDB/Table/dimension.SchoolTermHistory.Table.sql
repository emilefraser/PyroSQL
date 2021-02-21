SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[SchoolTermHistory]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[SchoolTermHistory](
	[TermID] [smallint] NOT NULL,
	[TermName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TermStartDate] [date] NULL,
	[TermEndDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
END
GO
