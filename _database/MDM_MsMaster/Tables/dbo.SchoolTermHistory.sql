SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [REFERENCE].[SchoolTermHistory](
	[TermID] [smallint] NOT NULL,
	[TermName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TermStartDate] [date] NULL,
	[TermEndDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]

GO
