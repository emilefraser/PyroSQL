SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimension].[Country_History]') AND type in (N'U'))
BEGIN
CREATE TABLE [dimension].[Country_History](
	[CountryID] [smallint] NOT NULL,
	[UN_Code] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISO_Code2] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISO_Code3] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryName] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CountryDomain] [varchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StartDT] [datetime2](7) NOT NULL,
	[EndDT] [datetime2](7) NOT NULL
) ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dimension].[Country_History]') AND name = N'ix_Country_History')
CREATE CLUSTERED INDEX [ix_Country_History] ON [dimension].[Country_History]
(
	[EndDT] ASC,
	[StartDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF, DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
