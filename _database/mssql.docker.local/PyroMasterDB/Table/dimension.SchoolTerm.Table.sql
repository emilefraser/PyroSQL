SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[SchoolTerm]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[SchoolTerm](
	[TermID] [smallint] IDENTITY(0,1) NOT NULL,
	[TermName] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TermStartDate] [date] NULL,
	[TermEndDate] [date] NULL,
	[CountryID] [smallint] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TermID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[DF__SchoolTer__Creat__3C3FDE67]') AND type = 'D')
BEGIN
ALTER TABLE [dimension].[SchoolTerm] ADD  DEFAULT (getdate()) FOR [CreatedDT]
END
GO
